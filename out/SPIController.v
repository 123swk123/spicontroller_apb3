// Generator : SpinalHDL v1.6.0    git head : 73c8d8e2b86b45646e9d0b2e729291f2b65e6be3
// Component : SPIController
// Git hash  : efc862516b2707ad08273625469bf60d3aec3d12


`define ctrlLogic_fsm_enumDefinition_binary_sequential_type [2:0]
`define ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT 3'b000
`define ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle 3'b001
`define ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd 3'b010
`define ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow 3'b011
`define ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh 3'b100


module SPIController (
  input      [7:0]    io_apb_PADDR,
  input      [0:0]    io_apb_PSEL,
  input               io_apb_PENABLE,
  output reg          io_apb_PREADY,
  input               io_apb_PWRITE,
  input      [31:0]   io_apb_PWDATA,
  output reg [31:0]   io_apb_PRDATA,
  output              io_apb_PSLVERROR,
  output              io_spiSCK,
  output              io_spiMOSI,
  output              io_spiCS,
  input               io_spiMISO,
  input               clk,
  input               resetn
);
  wire       [7:0]    fifoInOut_Q;
  wire                fifoInOut_Empty;
  wire                fifoInOut_Full;
  reg                 regControllerEnable;
  reg        [4:0]    regPrescaler;
  reg                 regCS;
  reg                 regFifoReset;
  reg                 regFifoWrEn;
  reg                 regFifoRdEn;
  reg        [7:0]    regFifoDataIn;
  reg                 regSkipTxReadback;
  wire                apbCtrl_askWrite;
  wire                apbCtrl_askRead;
  wire                apbCtrl_doWrite;
  wire                apbCtrl_doRead;
  reg        [10:0]   apbCountTx;
  reg        [10:0]   apbCountRx;
  reg                 regFifoDataOutRdy;
  reg        [2:0]    switch_spi_controller_apb3_l178;
  wire       [31:0]   _zz_regFifoDataIn;
  reg        [31:0]   _zz_io_apb_PRDATA;
  reg        [4:0]    ctrlLogic_prescaleCounter;
  reg                 ctrlLogic_regSCK;
  reg        [7:0]    ctrlLogic_regData;
  reg        [2:0]    ctrlLogic_spiDataShiftCounter;
  reg                 ctrlLogic_regDataBit0;
  reg                 ctrlLogic_shouldRdFifo;
  reg                 ctrlLogic_fsm_wantExit;
  reg                 ctrlLogic_fsm_wantStart;
  wire                ctrlLogic_fsm_wantKill;
  reg        [1:0]    _zz_when_State_l228;
  wire                when_spi_controller_apb3_l160;
  wire                when_spi_controller_apb3_l161;
  wire                when_spi_controller_apb3_l177;
  wire                when_spi_controller_apb3_l194;
  wire                when_spi_controller_apb3_l195;
  reg        `ctrlLogic_fsm_enumDefinition_binary_sequential_type ctrlLogic_fsm_stateReg;
  reg        `ctrlLogic_fsm_enumDefinition_binary_sequential_type ctrlLogic_fsm_stateNext;
  wire                _zz_when_StateMachine_l214;
  wire                _zz_when_StateMachine_l214_1;
  wire                when_State_l228;
  wire                when_spi_controller_apb3_l245;
  wire                when_spi_controller_apb3_l249;
  wire                when_spi_controller_apb3_l258;
  wire                when_spi_controller_apb3_l273;
  wire                when_spi_controller_apb3_l288;
  wire                when_spi_controller_apb3_l293;
  wire                when_spi_controller_apb3_l299;
  wire                when_spi_controller_apb3_l300;
  wire                when_spi_controller_apb3_l301;
  wire                when_spi_controller_apb3_l303;
  wire                when_StateMachine_l214;
  wire                when_StateMachine_l230;
  wire                when_spi_controller_apb3_l233;
  wire                when_StateMachine_l230_1;
  wire                when_StateMachine_l230_2;
  `ifndef SYNTHESIS
  reg [183:0] ctrlLogic_fsm_stateReg_string;
  reg [183:0] ctrlLogic_fsm_stateNext_string;
  `endif


  Fifo fifoInOut (
    .Clk      (clk              ), //i
    .Reset    (regFifoReset     ), //i
    .Data     (regFifoDataIn    ), //i
    .WrEn     (regFifoWrEn      ), //i
    .RdEn     (regFifoRdEn      ), //i
    .Q        (fifoInOut_Q      ), //o
    .Empty    (fifoInOut_Empty  ), //o
    .Full     (fifoInOut_Full   )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT : ctrlLogic_fsm_stateReg_string = "ctrlLogic_fsm_BOOT     ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : ctrlLogic_fsm_stateReg_string = "ctrlLogic_fsm_idle     ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : ctrlLogic_fsm_stateReg_string = "ctrlLogic_fsm_fifoRd   ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : ctrlLogic_fsm_stateReg_string = "ctrlLogic_fsm_clockLow ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : ctrlLogic_fsm_stateReg_string = "ctrlLogic_fsm_clockHigh";
      default : ctrlLogic_fsm_stateReg_string = "???????????????????????";
    endcase
  end
  always @(*) begin
    case(ctrlLogic_fsm_stateNext)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT : ctrlLogic_fsm_stateNext_string = "ctrlLogic_fsm_BOOT     ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : ctrlLogic_fsm_stateNext_string = "ctrlLogic_fsm_idle     ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : ctrlLogic_fsm_stateNext_string = "ctrlLogic_fsm_fifoRd   ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : ctrlLogic_fsm_stateNext_string = "ctrlLogic_fsm_clockLow ";
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : ctrlLogic_fsm_stateNext_string = "ctrlLogic_fsm_clockHigh";
      default : ctrlLogic_fsm_stateNext_string = "???????????????????????";
    endcase
  end
  `endif

  assign io_spiCS = regCS;
  always @(*) begin
    regFifoRdEn = 1'b0;
    case(io_apb_PADDR)
      8'h08 : begin
        if(apbCtrl_askRead) begin
          if(when_spi_controller_apb3_l160) begin
            regFifoRdEn = 1'b1;
          end
        end
      end
      8'h0c : begin
        if(apbCtrl_askRead) begin
          if(when_spi_controller_apb3_l195) begin
            regFifoRdEn = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l230) begin
      if(when_spi_controller_apb3_l233) begin
        regFifoRdEn = ctrlLogic_shouldRdFifo;
      end
    end
  end

  always @(*) begin
    io_apb_PREADY = 1'b1;
    case(io_apb_PADDR)
      8'h08 : begin
        if(apbCtrl_askRead) begin
          io_apb_PREADY = 1'b0;
          if(when_spi_controller_apb3_l161) begin
            io_apb_PREADY = 1'b1;
          end
        end
      end
      8'h0c : begin
        if(apbCtrl_askWrite) begin
          if(when_spi_controller_apb3_l177) begin
            io_apb_PREADY = 1'b0;
          end
        end
        if(apbCtrl_askRead) begin
          if(when_spi_controller_apb3_l194) begin
            io_apb_PREADY = 1'b0;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_apb_PRDATA = 32'h0;
    case(io_apb_PADDR)
      8'h0 : begin
        io_apb_PRDATA[5 : 5] = regControllerEnable;
        io_apb_PRDATA[7 : 7] = regCS;
        io_apb_PRDATA[16 : 16] = fifoInOut_Full;
        io_apb_PRDATA[17 : 17] = fifoInOut_Empty;
      end
      8'h04 : begin
        io_apb_PRDATA[10 : 0] = apbCountTx;
        io_apb_PRDATA[26 : 16] = apbCountRx;
      end
      8'h08 : begin
        io_apb_PRDATA[7 : 0] = fifoInOut_Q;
      end
      8'h0c : begin
        io_apb_PRDATA[31 : 0] = _zz_io_apb_PRDATA;
      end
      default : begin
      end
    endcase
  end

  assign io_apb_PSLVERROR = 1'b0;
  assign apbCtrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
  assign apbCtrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (! io_apb_PWRITE));
  assign apbCtrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
  assign apbCtrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
  always @(*) begin
    ctrlLogic_shouldRdFifo = 1'b0;
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
        if(regControllerEnable) begin
          ctrlLogic_shouldRdFifo = 1'b1;
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
        if(when_spi_controller_apb3_l288) begin
          if(when_spi_controller_apb3_l299) begin
            if(when_spi_controller_apb3_l303) begin
              ctrlLogic_shouldRdFifo = 1'b0;
            end else begin
              ctrlLogic_shouldRdFifo = 1'b1;
            end
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign io_spiSCK = ctrlLogic_regSCK;
  assign io_spiMOSI = ctrlLogic_regData[7];
  always @(*) begin
    ctrlLogic_fsm_wantExit = 1'b0;
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
        if(when_State_l228) begin
          if(!when_spi_controller_apb3_l245) begin
            if(!when_spi_controller_apb3_l249) begin
              ctrlLogic_fsm_wantExit = 1'b1;
            end
          end
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrlLogic_fsm_wantStart = 1'b0;
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
      end
      default : begin
        ctrlLogic_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ctrlLogic_fsm_wantKill = 1'b0;
  assign _zz_regFifoDataIn = io_apb_PWDATA[31 : 0];
  assign when_spi_controller_apb3_l160 = (io_apb_PREADY == 1'b0);
  assign when_spi_controller_apb3_l161 = (regFifoDataOutRdy == 1'b1);
  assign when_spi_controller_apb3_l177 = (switch_spi_controller_apb3_l178 < 3'b100);
  assign when_spi_controller_apb3_l194 = (switch_spi_controller_apb3_l178 < 3'b101);
  assign when_spi_controller_apb3_l195 = (switch_spi_controller_apb3_l178 < 3'b100);
  assign _zz_when_StateMachine_l214 = (ctrlLogic_fsm_stateReg == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd);
  assign _zz_when_StateMachine_l214_1 = (ctrlLogic_fsm_stateNext == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd);
  always @(*) begin
    ctrlLogic_fsm_stateNext = ctrlLogic_fsm_stateReg;
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
        if(regControllerEnable) begin
          ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd;
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
        if(when_State_l228) begin
          if(when_spi_controller_apb3_l245) begin
            ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow;
          end else begin
            if(when_spi_controller_apb3_l249) begin
              ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow;
            end else begin
              ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT;
            end
          end
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
        if(when_spi_controller_apb3_l273) begin
          ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh;
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
        if(when_spi_controller_apb3_l288) begin
          if(when_spi_controller_apb3_l293) begin
            ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow;
          end
          if(when_spi_controller_apb3_l299) begin
            ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd;
          end
        end
      end
      default : begin
      end
    endcase
    if(ctrlLogic_fsm_wantStart) begin
      ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle;
    end
    if(ctrlLogic_fsm_wantKill) begin
      ctrlLogic_fsm_stateNext = `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT;
    end
  end

  assign when_State_l228 = (_zz_when_State_l228 <= 2'b01);
  assign when_spi_controller_apb3_l245 = (11'h0 < apbCountTx);
  assign when_spi_controller_apb3_l249 = (11'h0 < apbCountRx);
  assign when_spi_controller_apb3_l258 = ((ctrlLogic_spiDataShiftCounter == 3'b000) && (regSkipTxReadback == 1'b0));
  assign when_spi_controller_apb3_l273 = (ctrlLogic_prescaleCounter == regPrescaler);
  assign when_spi_controller_apb3_l288 = (ctrlLogic_prescaleCounter == regPrescaler);
  assign when_spi_controller_apb3_l293 = (3'b000 < ctrlLogic_spiDataShiftCounter);
  assign when_spi_controller_apb3_l299 = (ctrlLogic_spiDataShiftCounter == 3'b000);
  assign when_spi_controller_apb3_l300 = (11'h0 < apbCountTx);
  assign when_spi_controller_apb3_l301 = (11'h0 < apbCountRx);
  assign when_spi_controller_apb3_l303 = (apbCountTx == 11'h001);
  assign when_StateMachine_l214 = (_zz_when_StateMachine_l214 && (! _zz_when_StateMachine_l214_1));
  assign when_StateMachine_l230 = ((! _zz_when_StateMachine_l214) && _zz_when_StateMachine_l214_1);
  assign when_spi_controller_apb3_l233 = (11'h0 < apbCountTx);
  assign when_StateMachine_l230_1 = ((! (ctrlLogic_fsm_stateReg == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow)) && (ctrlLogic_fsm_stateNext == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow));
  assign when_StateMachine_l230_2 = ((! (ctrlLogic_fsm_stateReg == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh)) && (ctrlLogic_fsm_stateNext == `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh));
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      regControllerEnable <= 1'b0;
      regPrescaler <= 5'h0;
      regCS <= 1'b1;
      regFifoReset <= 1'b0;
      regSkipTxReadback <= 1'b0;
      apbCountTx <= 11'h0;
      apbCountRx <= 11'h0;
      regFifoDataOutRdy <= 1'b0;
      switch_spi_controller_apb3_l178 <= 3'b000;
      _zz_io_apb_PRDATA <= 32'h0;
      ctrlLogic_prescaleCounter <= 5'h0;
      ctrlLogic_regSCK <= 1'b0;
      ctrlLogic_spiDataShiftCounter <= 3'b111;
      ctrlLogic_regDataBit0 <= 1'b0;
      ctrlLogic_fsm_stateReg <= `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_BOOT;
    end else begin
      regFifoDataOutRdy <= regFifoRdEn;
      case(io_apb_PADDR)
        8'h0 : begin
          if(apbCtrl_doWrite) begin
            regPrescaler <= io_apb_PWDATA[4 : 0];
            regControllerEnable <= io_apb_PWDATA[5];
            regSkipTxReadback <= io_apb_PWDATA[6];
            regCS <= io_apb_PWDATA[7];
            regFifoReset <= io_apb_PWDATA[16];
          end
        end
        8'h04 : begin
          if(apbCtrl_doWrite) begin
            apbCountTx <= io_apb_PWDATA[10 : 0];
            apbCountRx <= io_apb_PWDATA[26 : 16];
          end
        end
        8'h0c : begin
          if(apbCtrl_askWrite) begin
            switch_spi_controller_apb3_l178 <= (switch_spi_controller_apb3_l178 + 3'b001);
            case(switch_spi_controller_apb3_l178)
              3'b000 : begin
              end
              3'b001 : begin
              end
              3'b010 : begin
              end
              3'b011 : begin
              end
              default : begin
                switch_spi_controller_apb3_l178 <= 3'b000;
              end
            endcase
          end
          if(apbCtrl_askRead) begin
            switch_spi_controller_apb3_l178 <= (switch_spi_controller_apb3_l178 + 3'b001);
            case(switch_spi_controller_apb3_l178)
              3'b001 : begin
                _zz_io_apb_PRDATA[7 : 0] <= fifoInOut_Q;
              end
              3'b010 : begin
                _zz_io_apb_PRDATA[15 : 8] <= fifoInOut_Q;
              end
              3'b011 : begin
                _zz_io_apb_PRDATA[23 : 16] <= fifoInOut_Q;
              end
              3'b100 : begin
                _zz_io_apb_PRDATA[31 : 24] <= fifoInOut_Q;
              end
              3'b101 : begin
                switch_spi_controller_apb3_l178 <= 3'b000;
              end
              default : begin
              end
            endcase
          end
        end
        default : begin
        end
      endcase
      ctrlLogic_fsm_stateReg <= ctrlLogic_fsm_stateNext;
      case(ctrlLogic_fsm_stateReg)
        `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
        end
        `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
          if(when_State_l228) begin
            if(!when_spi_controller_apb3_l245) begin
              if(when_spi_controller_apb3_l249) begin
                regSkipTxReadback <= 1'b0;
              end else begin
                regControllerEnable <= 1'b0;
              end
            end
          end
        end
        `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
          if(when_spi_controller_apb3_l273) begin
            ctrlLogic_regDataBit0 <= io_spiMISO;
          end
          ctrlLogic_prescaleCounter <= (ctrlLogic_prescaleCounter + 5'h01);
        end
        `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
          if(when_spi_controller_apb3_l288) begin
            if(when_spi_controller_apb3_l293) begin
              ctrlLogic_spiDataShiftCounter <= (ctrlLogic_spiDataShiftCounter - 3'b001);
            end
            if(when_spi_controller_apb3_l299) begin
              if(when_spi_controller_apb3_l300) begin
                apbCountTx <= (apbCountTx - 11'h001);
              end
              if(when_spi_controller_apb3_l301) begin
                apbCountRx <= (apbCountRx - 11'h001);
              end
              ctrlLogic_regSCK <= 1'b0;
            end
          end
          ctrlLogic_prescaleCounter <= (ctrlLogic_prescaleCounter + 5'h01);
        end
        default : begin
        end
      endcase
      if(when_StateMachine_l214) begin
        ctrlLogic_spiDataShiftCounter <= 3'b111;
      end
      if(when_StateMachine_l230_1) begin
        ctrlLogic_prescaleCounter <= 5'h0;
        ctrlLogic_regSCK <= 1'b0;
      end
      if(when_StateMachine_l230_2) begin
        ctrlLogic_prescaleCounter <= 5'h0;
        ctrlLogic_regSCK <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    regFifoDataIn <= 8'h0;
    regFifoWrEn <= 1'b0;
    case(io_apb_PADDR)
      8'h08 : begin
        if(apbCtrl_doWrite) begin
          regFifoDataIn <= io_apb_PWDATA[7 : 0];
          regFifoWrEn <= 1'b1;
        end
      end
      8'h0c : begin
        if(apbCtrl_askWrite) begin
          regFifoWrEn <= 1'b1;
          case(switch_spi_controller_apb3_l178)
            3'b000 : begin
              regFifoDataIn <= _zz_regFifoDataIn[7 : 0];
            end
            3'b001 : begin
              regFifoDataIn <= _zz_regFifoDataIn[15 : 8];
            end
            3'b010 : begin
              regFifoDataIn <= _zz_regFifoDataIn[23 : 16];
            end
            3'b011 : begin
              regFifoDataIn <= _zz_regFifoDataIn[31 : 24];
            end
            default : begin
              regFifoWrEn <= 1'b0;
            end
          endcase
        end
      end
      default : begin
      end
    endcase
    case(ctrlLogic_fsm_stateReg)
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_idle : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_fifoRd : begin
        _zz_when_State_l228 <= (_zz_when_State_l228 - 2'b01);
        if(when_State_l228) begin
          if(when_spi_controller_apb3_l245) begin
            ctrlLogic_regData <= fifoInOut_Q;
          end else begin
            if(when_spi_controller_apb3_l249) begin
              ctrlLogic_regData <= 8'hff;
            end
          end
          if(when_spi_controller_apb3_l258) begin
            regFifoDataIn <= ctrlLogic_regData;
            regFifoWrEn <= 1'b1;
          end
        end
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockLow : begin
      end
      `ctrlLogic_fsm_enumDefinition_binary_sequential_ctrlLogic_fsm_clockHigh : begin
        if(when_spi_controller_apb3_l288) begin
          ctrlLogic_regData[7 : 1] <= ctrlLogic_regData[6 : 0];
          ctrlLogic_regData[0] <= ctrlLogic_regDataBit0;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l230) begin
      _zz_when_State_l228 <= 2'b10;
    end
  end


endmodule
