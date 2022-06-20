`ifndef BACKDOOR_CONNECTIONS_SV
 `define BACKDOOR_CONNECTIONS_SV
// This file just connects inner DUT connections to signals defined in the top.sv.
// This is needed because some verification components need to see these inner signals
// for automated checking.

// Instruction interface backdoor connections
assign DUT.instr_ready = backdoor_instr_vif.instr_ready; 
assign DUT.instr_mem_read=backdoor_instr_vif.instr_mem_read;
assign backdoor_instr_vif.instr_mem_address = DUT.instr_mem_address;
assign backdoor_instr_vif.instr_mem_flush = DUT.instr_mem_flush;
assign backdoor_instr_vif.instr_mem_en = DUT.instr_mem_en;

// Register bank backdoor connections
assign backdoor_register_bank_vif.rd_we_i=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rd_we_i;
assign backdoor_register_bank_vif.rs1_address_i=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rs1_address_i;
assign backdoor_register_bank_vif.rs2_address_i=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rs2_address_i;
assign backdoor_register_bank_vif.rs1_data_o=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rs1_data_o;
assign backdoor_register_bank_vif.rs2_data_o=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rs2_data_o;
assign backdoor_register_bank_vif.rd_address_i=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rd_address_i;
assign backdoor_register_bank_vif.rd_data_i=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.rd_data_i;
assign backdoor_register_bank_vif.scalar_reg_bank=DUT.riscv_v_inst.scalar_core_inst.data_path_1.register_bank_1.white_box_inst.scalar_reg_bank;

// Scalaro core data interface

//assign DUT.data_ready = backdoor_sc_data_if.data_ready_i;
assign DUT.data_ready=1'b1;
assign backdoor_sc_data_vif.data_mem_address_o=DUT.data_mem_address; 
assign DUT.data_mem_read = backdoor_sc_data_vif.data_mem_read_i;
assign backdoor_sc_data_vif.data_mem_write_o=DUT.data_mem_write;
assign backdoor_sc_data_vif.data_mem_we_o=DUT.data_mem_we;
assign backdoor_sc_data_vif.data_mem_re_o=DUT.data_mem_re;

// ********Vector core data IF***************

//read IF
assign backdoor_v_data_vif.ctrl_raddr_offset_o = DUT.riscv_v_inst.ctrl_raddr_offset_o;
assign backdoor_v_data_vif.ctrl_rxfer_size_o = DUT.riscv_v_inst.ctrl_rxfer_size_o;
assign backdoor_v_data_vif.ctrl_rstart_o = DUT.riscv_v_inst.ctrl_rstart_o;

assign backdoor_v_data_vif.rd_tready_o = DUT.riscv_v_inst.rd_tready_o;
assign DUT.riscv_v_inst.ctrl_rdone_i = backdoor_v_data_vif.ctrl_rdone_i;
assign DUT.riscv_v_inst.rd_tdata_i = backdoor_v_data_vif.rd_tdata_i;
assign DUT.riscv_v_inst.rd_tvalid_i = backdoor_v_data_vif.rd_tvalid_i;
assign DUT.riscv_v_inst.rd_tlast_i = backdoor_v_data_vif.rd_tlast_i;
// Write if
assign backdoor_v_data_vif.ctrl_waddr_offset_o = DUT.riscv_v_inst.ctrl_waddr_offset_o;
assign backdoor_v_data_vif.ctrl_wxfer_size_o = DUT.riscv_v_inst.ctrl_wxfer_size_o;
assign backdoor_v_data_vif.ctrl_wstart_o = DUT.riscv_v_inst.ctrl_wstart_o;

assign DUT.riscv_v_inst.wr_tready_i = backdoor_v_data_vif.wr_tready_i;
assign DUT.riscv_v_inst.ctrl_wdone_i = backdoor_v_data_vif.ctrl_wdone_i;
assign backdoor_v_data_vif.wr_tdata_o = DUT.riscv_v_inst.wr_tdata_o;
assign backdoor_v_data_vif.wr_tvalid_o = DUT.riscv_v_inst.wr_tvalid_o;

/***********************************************************/
// Vector core VRF backdoor interface


//LANE0 VRF_INIT
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_lvt_banks[0].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[0][0];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_lvt_banks[1].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[0][1];

assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][0][0];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][0][1];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][0][2];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][0][3];

assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][1][0];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][1][1];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][1][2];
assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[0][1][3];

generate
   if (V_LANES > 1)
   begin
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_lvt_banks[0].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[1][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_lvt_banks[1].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[1][1];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][0][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][0][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][0][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][0][3];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][1][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][1][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][1][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[1].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[1][1][3];      
   end

   if (V_LANES > 2)
   begin
            assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_lvt_banks[0].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[2][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_lvt_banks[1].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[2][1];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][0][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][0][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][0][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][0][3];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][1][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][1][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][1][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[2].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[2][1][3];


            assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_lvt_banks[0].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[3][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_lvt_banks[1].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt[3][1];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][0][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][0][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][0][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][0][3];

      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[0].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][1][0];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[1].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][1][1];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[2].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][1][2];
      assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[3].Vector_Lane_inst.VRF_inst.gen_read_banks[1].gen_RAMs[3].gen_BRAM.READ_RAMs.BRAM = vrf_read_ram[3][1][3];   
   end
endgenerate


//assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_read_banks[0].gen_RAMs[0].gen_BRAM.READ_BRAMs.BRAM = vrf_lvt;
//assign DUT.riscv_v_inst.vector_core_inst.Vlane_with_low_lvl_ctrl_inst.VL_instances[0].Vector_Lane_inst.VRF_inst.gen_lvt_banks[0].gen_RAMs[0].gen_BRAM.LVT_RAMs.BRAM = vrf_lvt;





`endif
