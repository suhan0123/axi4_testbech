//AXI_MASTER_MONITOR PSEUDOCODE:
//-----------------------------------------------------------------------------------
//axi_master_monitor is user-defined class which is extended from uvm_monitor which is a pre-defined uvm class
class axi_master_monitor extends uvm_monitor;

//Factory registration
`uvm_component_utils(axi_master_monitor)

//Handle to virtual interface
virtual axi_master_interface vif;
  
//Declaring a handle of axi_master_sequence_item
axi_master_sequence_item req_op;

//Declaring 5 analysis ports to put 5 channel signals to 5 different FIFOs in scoreboard
  uvm_analysis_port#(axi4_master_sequence_item) axi4_master_analysis_port;

//Different methods present in the class that are defined outside class using extern keyword
extern function new(string name = "axi4_master_monitor_proxy", uvm_component parent = null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual function void connect_phase(uvm_phase phase);
extern virtual function void end_of_elaboration_phase(uvm_phase phase);
extern virtual task run_phase(uvm_phase phase);

endclass : axi_master_monitor_

//--------------------------------------------------------------------------------
//Function: class constructor
function axi_master_monitor::new(string name = "axi_master_monitor", uvm_component parent = null);
  super.new(name, parent)
  axi4_master_analysis_port   = new("axi4_master_read_analysis_port",this);
endfunction : new

//Function: Build phase
function void axi4_master_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual axi_master_interface)::get(this, "", "vif", vif))a
      `uvm_fatal("Monitor: ", "No vif is found!")
  end 
endfunction : build_phase 

//Function: connect phase
function void axi4_master_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

//Task: run phase
task axi_master_monitor::run_phase(uvm_phase phase);
  forever begin : FOREVER
    if(!vif.aresetn) begin : LOW_RESET
    fork  //to ensure both read and write signals are monitored parallely
      begin : WRITE_PROCESS
          fork 
            begin : WRITE_ADDRESS
              //Taking data of write address channel
              do begin
                @(posedge vif.m_mp.clk);
              end
              while(vif_m_mp.m_cb.awvalid != 1 && vif.m_mp.m_cb.awready != 1);
              req_op.s_axi_awid    = vif.m_mp.m_cb.s_axi_awid ;
              req_op.s_axi_awaddr  = vif.m_mp.m_cb.s_axi_awaddr;
              req_op.s_axi_awlen   = vif.m_mp.m_cb.s_axi_awlen;
              req_op.s_axi_awsize  = vif.m_mp.m_cb.s_axi_awsize;
              req_op.s_axi_awburst =vif.m_mp.m_cb.s_axi_awburst;
              req_op.s_axi_awlock  = vif.m_mp.m_cb.s_axi_awlock;
              req_op.s_axi_awcache = vif.m_mp.m_cb.s_axi_awcache;
              req_op.s_axi_awprot  = vif.m_mp.m_cb.s_axi_awprot;
            end : WRITE_ADDRESS
            
            begin : WRITE_DATA
              static int i;
              //Taking data of write data channel
              //forever begin
              do begin
                @(posedge vif.m_mp.clk);
              end
                while(vif.m_mp.m_cb.s_axi_wvalid != 1 && vif.m_mp.m_cb.s_axi_wready != 1);
               req_op.s_axi_wdata[i] = vif.m_mp.m_cb.s_axi_wdata;
               req_op.s_axi_wstrb[i] = vif.m_mp.m_cb.s_axi_wstrb;
               req_op.s_axi_wuser[i] = vif.m_mp.m_cb.s_axi_wuser;
               req_op.s_axi_wlast = vif.m_mp.m_cb.s_axi_wlast;
               req_op.s_axi_wvalid  = vif.m_mp.m_cb.s_axi_wvalid;
               req_op.s_axi_wready  = vif.m_mp.m_cb.s_axi_wready;
                if(req_op.wlast == 1) begin
                  i = 0;
                  break;
                end
                  i++;
            end : WRITE_DATA  
          join
          begin : WRITE_RESPONSE
          //Taking data of write response channel
          do begin
            @(posedge vif.m_mp.clk);
          end
          while(vif.m_mp.m_cb.s_axi_bvalid != 1 && vif.m_mp.m_cb.s_axi_bready != 1);
         req_op.s_axi_bid      = vif.m_mp.m_cb.s_axi_bid;
         req_op.s_axi_bresp    = vif.m_mp.m_cb.s_axi_bresp;
         req_op.s_axi_bvalid   = vif.m_mp.m_cb.s_axi_bvalid;
         req_op.s_axi_bready   = vif.m_mp.m_cb.s_axi_bready;
          end : WRITE_RESPONSE   
      end : WRITE_PROCESS
      
        begin : READ_PROCESS
            //Taking data of read address channel
              do begin
                @(posedge vif.m_mp.clk);
              end
              while(vif.m_mp.m_cb.s_axi_arvalid != 1 && vif.m_mp.m_cb.s_axi_arready != 1);
              req_op.s_axi_arid    = vif.m_mp.m_cb.s_axi_arid ;
              req_op.s_axi_araddr  = vif.m_mp.m_cb.s_axi_araddr;
              req_op.s_axi_arlen   = vif.m_mp.m_cb.s_axi_arlen;
              req_op.s_axi_arsize  = vif.m_mp.m_cb.s_axi_arsize;
              req_op.s_axi_arburst = vif.m_mp.m_cb.s_axi_arburst;
              req_op.s_axi_arlock  = vif.m_mp.m_cb.s_axi_arlock;
              req_op.s_axi_arcache = vif.m_mp.m_cb.s_axi_arcache;
              req_op.s_axi_arprot  = vif.m_mp.m_cb.s_axi_arprot;
              req_op.s_axi_arvalid = vif.m_mp.m_cb.s_axi_arvalid;
              req_op.s_axi_arready = vif.m_mp.m_cb.s_axi_arready;
          
              static int j;
              //Taking data of read data channel
              do begin
                @(posedge vif.m_mp.clk);
              end
              while(vif.m_mp.m_cb.s_axi_rvalid != 1 && vif.m_mp.m_cb.s_axi_rready != 1);
               req_op.rid = vif.m_mp.m_cb.rid;
               req_op.rdata[j] = vif.m_mp.m_cb.s_axi_rdata;
               req_op.s_axi_ruser = vif.m_mp.m_cb.s_axi_ruser;
               req_op.s_axi_rresp = vif.m_mp.m_cb.s_axi_rresp;
               req_op.s_axi_rlast = vif.m_mp.m_cb.s_axi_rlast;
               req_op.s_axi_rvalid = vif.m_mp.m_cb.s_axi_rvalid;
               req_op.s_axi_rvalid = vif.m_mp.m_cb.s_axi_rvalid;
                if(req_op.rlast == 1) begin
                  j = 0;
                  break;
                end
                  j++;
              end : READ_PROCESS
            
          end : LOW_RESET
        end : FOREVER
    join_any
     axi4_master_analysis_port.write(req_op);
    wait fork;
  end
endtask
      
