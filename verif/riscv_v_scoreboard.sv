
`uvm_analysis_imp_decl(_v)
`include "defines.sv"
class riscv_v_scoreboard extends uvm_scoreboard;

   // control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;
   int num_of_tr;
   int match_num;

   const logic [2 : 0] OPIVV = 3'b000;
   const logic [2 : 0] OPIVX = 3'b100;
   const logic [2 : 0] OPIVI = 3'b011;
   const logic [2 : 0] OPMVV = 3'b010;
   const logic [2 : 0] OPMVX = 3'b110;
   const logic [2 : 0] OPCFG = 3'b111;
   // This TLM port is used to connect the scoreboard to the monitor
   virtual interface axi4_if v_axi4_vif;
   virtual interface backdoor_v_instr_if backdoor_v_instr_vif;
   uvm_analysis_imp_v#(bd_v_instr_if_seq_item, riscv_v_scoreboard) item_collected_imp_v;
   
   logic [31:0] vrf_read_ram [31:0][`VLEN/32-1:0];

   typedef enum logic [6:0] {v_arith=7'b1010111, v_store=7'b0100111, v_load=7'b0000111} vector_opcodes;
   
   logic [6:0] 	opcode;
   int 		skip_2_instructions = 0;
   
   `uvm_component_utils_begin(riscv_v_scoreboard)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   function new(string name = "riscv_v_scoreboard", uvm_component parent = null);
      super.new(name,parent);
      item_collected_imp_v = new("item_collected_imp_v", this);
   endfunction : new

   function void build_phase (uvm_phase phase);
      logic [$clog2(`V_LANES)-1:0] vrf_vlane; 
      logic [1:0] 		   byte_sel;      
      int 			   vreg_addr_offset;
      int 			   vreg_to_read;
      super.build_phase(phase);
      
      if (!uvm_config_db#(virtual axi4_if)::get(this, "", "v_axi4_if", v_axi4_vif)) // needed for ddr access
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".v_axi4_vif"})
      if (!uvm_config_db#(virtual backdoor_v_instr_if)::get(this, "", "backdoor_v_instr_if", backdoor_v_instr_vif)) // needed for initialization of vrf ref model
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".backdoor_v_instr_vif"})
      //init ref model vrf
      for (int i=0; i<32; i++)
	for (logic[31:0] j=0; j<`VLEN/8; j++)
	begin
	   vrf_vlane=j[$clog2(`V_LANES)-1:0];
	   byte_sel=j[$clog2(`V_LANES) +:2];
	   //byte_sel=j[3:2];
	   vreg_to_read=i*(`VLEN/32/`V_LANES);
	   vreg_addr_offset = j[$clog2(`V_LANES) + 2 +: 27];
	   $display ("vrf_vlane=%0d, \t vreg_to_read+vreg_addr_offset=%0d", vrf_vlane, vreg_to_read+vreg_addr_offset);	   
	   vrf_read_ram[i][j[31:2]][j[1:0]*8 +: 8] = backdoor_v_instr_vif.vrf_read_ram[vrf_vlane][0][0][vreg_to_read+vreg_addr_offset][byte_sel*8+:8] ^ 
						     backdoor_v_instr_vif.vrf_read_ram[vrf_vlane][1][0][vreg_to_read+vreg_addr_offset][byte_sel*8+:8];

	end
      foreach(vrf_read_ram[i])
	foreach(vrf_read_ram[i][j])
	  $display ("vrf_read_ram[%0d][%0d]=%0d", i, j, vrf_read_ram[i][j]);
   endfunction

   function write_v (bd_v_instr_if_seq_item tr);
      bd_v_instr_if_seq_item tr_clone;      
      $cast(tr_clone, tr.clone());

      `uvm_info(get_type_name(),
                $sformatf("V_SCBD:vMonitor sent...\n%s", tr_clone.sprint()),
                UVM_MEDIUM)
      num_of_tr++;
      if (tr_clone.v_instruction[6:0]==v_arith)
	arith_instr_check(tr_clone);
      //if (tr_clone.v_instruction[6:0]==v_arith && tr_clone.v_instruction[31:26]==6'b001110 || tr_clone.v_instruction[31:26]==6'b001111) // slides      
	//arith_instr_check(tr_clone);
      //if (tr_clone.v_instruction[6:0]==v_arith && tr_clone.v_instruction[31:29]==3'b000) // reductions
	//arith_instr_check(tr_clone);
      
   endfunction: write_v
      

   function void arith_instr_check(bd_v_instr_if_seq_item tr);
      logic [4:0] rs1;
      logic [4:0] rs2;
      logic [4:0] rd;
      logic 	  vm;
      logic [2:0] funct3;
      logic [5:0] funct6;
      logic [31:0] op1;
      logic [31:0] op2;
      logic [31:0] op1_sign_ext;
      logic [31:0] op2_sign_ext;
      int 	   vrf_addr_offset;
      int 	   vreg_to_update;
      int 	   element_idx;
      int 	   vrf_vlane;
      int 	   byte_sel;
      logic [7:0]  dut_vrf_data;
      int 	   match=0;
      logic [1:0]  sew;
      logic [31:0] res;
      rs1=tr.v_instruction[19:15];
      rs2=tr.v_instruction[24:20];
      rd=tr.v_instruction[11:7];
      vm=tr.v_instruction[25];
      funct3=tr.v_instruction[14:12];
      funct6=tr.v_instruction[31:26];
      
      for (int i=0; i<tr.vl; i++)
      begin
	 sew = ~(tr.sew[1:0] + 1);
	 element_idx =  i[sew +: 32];

	 if (tr.sew==3'b000)
	 begin
	    op1={24'b0, vrf_read_ram[rs1][element_idx][tr.vl[1:0]*8 +:8]};
	    if (funct3 == OPIVV || funct3 == OPMVV)
	      op2={24'b0, vrf_read_ram[rs2][element_idx][tr.vl[1:0]*8 +:8]};
	    else if (funct3 == OPIVX || funct3 == OPMVX)
	      op2={24'b0, tr.scalar[7:0]};
	    else
	      op2={27'b0, tr.v_instruction[19:15]};//immediate

	    op1_sign_ext = {{25{op1[7]}}, op1[6:0]};
	    op2_sign_ext = {{25{op2[7]}}, op2[6:0]};
	    res = sc_calculate_arith(op1_sign_ext, op2_sign_ext, funct6, funct3);
	    vrf_read_ram[rd][element_idx][tr.vl[1:0]*8 +: 8]=res[7:0];

	    $display("op1_sign_ext=%0d, op2_sign_ext=%0d, res[%0d][%0d]=%0d", op1_sign_ext, op2_sign_ext, rd, element_idx, vrf_read_ram[rd][element_idx]);
	 end
	 else if (tr.sew==3'b001)
	 begin
	    op1={16'b0, vrf_read_ram[rs1][element_idx][tr.vl[0]*16 +:16]};
	    if (funct3 == OPIVV || funct3 == OPMVV)
	      op2={16'b0, vrf_read_ram[rs2][element_idx][tr.vl[0]*16 +:16]};
	    else if (funct3 == OPIVX || funct3 == OPMVX)
	      op2={16'b0, tr.scalar[15:0]};
	    else
	      op2={27'b0, tr.v_instruction[19:15]};//immediate

	    op1_sign_ext = {{17{op1[15]}}, op1[14:0]};
	    op2_sign_ext = {{17{op2[15]}}, op2[14:0]};
	    res = sc_calculate_arith(op1_sign_ext, op2_sign_ext, funct6, funct3);
	    vrf_read_ram[rd][element_idx][tr.vl[0]*16 +: 16]=res[15:0];
	    $display("op1_sign_ext=%0d, op2_sign_ext=%0d, res[%0d][%0d]=%0d", op1_sign_ext, op2_sign_ext, rd, element_idx, vrf_read_ram[rd][element_idx]);
	 end
	 else
	 begin
	    op1=vrf_read_ram[rs1][element_idx][31:0];
	    if (funct3 == OPIVV || funct3 == OPMVV)
	      op2=vrf_read_ram[rs2][element_idx][31:0];
	    else if (funct3 == OPIVX || funct3 == OPMVX)
	      op2=tr.scalar;
	    else
	      op2={27'b0, tr.v_instruction[19:15]};//immediate
	    op1_sign_ext = op1;
	    op2_sign_ext = op2;
	    res = sc_calculate_arith(op1_sign_ext, op2_sign_ext, funct6, funct3);
	    vrf_read_ram[rd][element_idx]=res;
	    $display("op1_sign_ext=%0d, op2_sign_ext=%0d, res[%0d][%0d]=%0d", op1_sign_ext, op2_sign_ext, rd, element_idx, vrf_read_ram[rd][element_idx]);
	 end

	 
	 
      end // for (int i=0; i<tr.vl; i++)

      vreg_to_update = rd*(`VLEN/32/`V_LANES);
	for (logic[31:0] j=0; j<`VLEN/8; j++)
	begin
	   vrf_vlane=j[$clog2(`V_LANES)-1:0]; // 1:0
	   byte_sel=j[$clog2(`V_LANES) +:2];
	   vrf_addr_offset = j[$clog2(`V_LANES) + 2 +: 27];
	   dut_vrf_data = backdoor_v_instr_vif.vrf_read_ram[vrf_vlane][0][0][vreg_to_update+vrf_addr_offset][byte_sel*8 +: 8] ^
			  backdoor_v_instr_vif.vrf_read_ram[vrf_vlane][1][0][vreg_to_update+vrf_addr_offset][byte_sel*8 +: 8];
	   //$display("vrf_addr_offset=%0d, vreg_to_update=%0d",vrf_addr_offset, vreg_to_update);
	   assert (vrf_read_ram[rd][j[31:2]][j[1:0]*8 +: 8] == dut_vrf_data)
	   
	     begin
		$display("instruction: %0x \t expected result[%0d][%0d][%0d]: %0x, dut_result[%0d][%0d][%0d]: %0x", tr.v_instruction, 
			 rd, j[31:2], j[1:0], vrf_read_ram[rd][j[31:2]][j[1:0]*8 +: 8], //exp result
			 vrf_vlane, vreg_to_update+vrf_addr_offset, byte_sel, dut_vrf_data);
		match_num++;
		match = 1;	
	   end
	   else
	   begin
	      match = 0;
	      `uvm_error("VECTOR_MISSMATCH", $sformatf("instruction: %0x \t expected result[%0d][%0d][%0d]: %0x, dut_result[%0d][%0d][%0d]: %0x", tr.v_instruction, 
						       rd, j[31:2], j[1:0], vrf_read_ram[rd][j[31:2]][j[1:0]*8 +: 8], //exp result
						       vrf_vlane, vreg_to_update+vrf_addr_offset, byte_sel, dut_vrf_data)) // dut result
	   end	   
	end
      if (match == 1)
      begin
	 `uvm_info(get_type_name(), $sformatf("V_MATCH: instruction: %0x", tr.v_instruction), UVM_MEDIUM)
      end
   endfunction


   function logic [31:0] sc_calculate_arith (logic [31:0] op1, logic[31:0] op2, logic [5:0] funct6, logic [2:0] funct3);
      bit funct7_5;
      logic [31:0] res;

      if (funct3 == OPIVV || funct3 == OPIVX || funct3 == OPIVI)
	case (funct6)
	   6'b000000: begin	    
	      res = op1 + op2;	    
	   end
	   6'b000001: res = op1 - op2;
	   6'b000010: res = op1 - op2;
	   
	   6'b001001: res = op1 & op2;
	   6'b001010: res = op1 | op2;
	   6'b001011: res = op1 ^ op2;
	   6'b011000: res = op1 == op2;
	   6'b011001: res = op1 != op2;
	   6'b011010: res = unsigned'(op1) < unsigned'(op2);
	   6'b011011: res = signed'(op1) < signed'(op2);
	   6'b011100: res = unsigned'(op1) <= unsigned'(op2);
	   6'b011101: res = signed'(op1) <= signed'(op2);
	   6'b011110: res = unsigned'(op1) > unsigned'(op2);
	   6'b011111: res = signed'(op1) > signed'(op2);

	endcase // case (funct6)
      return res;
   endfunction // sc_calculate_arith

   function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("RISCV scoreboard examined: %0d TRANSACTIONS", num_of_tr), UVM_LOW);
      `uvm_info(get_type_name(), $sformatf("Calc scoreboard examined: %0d MATCHES", match_num), UVM_LOW);
   endfunction : report_phase
endclass : riscv_v_scoreboard
