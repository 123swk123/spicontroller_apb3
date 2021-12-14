package SPIController

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb.{Apb3SlaveFactory, Apb3}
import java.io.PrintWriter
import spinal.lib.bus.misc.BusSlaveFactoryWrite
import spinal.lib.fsm._
import org.apache.commons.io.filefilter.TrueFileFilter
import spinal.lib.bus.misc.BusSlaveFactoryRead

//Hardware definition
object SynthesisTool extends Enumeration {
    type SynthesisTool = Value
    val Vivado, Gowin = Value
}
import SynthesisTool._

class Fifo(dataWidth: Int, toolType: SynthesisTool) extends BlackBox {
    val io = new Bundle{
        val clk = in Bool()
        val reset = in Bool()
        val dataIn = in UInt(dataWidth bits)
        val writeEn = in Bool()
        val readEn = in Bool()
        val dataOut = out UInt(dataWidth bits)
        val empty = out Bool()
        val full = out Bool()
    }

    // Remove io_ prefix
    noIoPrefix()

    private def renameIO():Unit = {
        io.flatten.foreach(bt => {
            if (toolType == Gowin) {
                if(bt.getName() == "clk") bt.setName("Clk")
                if(bt.getName() == "reset") bt.setName("Reset")
                if(bt.getName() == "dataIn") bt.setName("Data")
                if(bt.getName() == "writeEn") bt.setName("WrEn")
                if(bt.getName() == "readEn") bt.setName("RdEn")
                if(bt.getName() == "dataOut") bt.setName("Q")
                if(bt.getName() == "empty") bt.setName("Empty")
                if(bt.getName() == "full") bt.setName("Full")
            }
            else if (toolType == Vivado) {
                if(bt.getName() == "clk") bt.setName("clk")
                if(bt.getName() == "reset") bt.setName("srst")
                if(bt.getName() == "dataIn") bt.setName("din")
                if(bt.getName() == "writeEn") bt.setName("wr_en")
                if(bt.getName() == "readEn") bt.setName("rd_en")
                if(bt.getName() == "dataOut") bt.setName("dout")
                if(bt.getName() == "empty") bt.setName("empty")
                if(bt.getName() == "full") bt.setName("full")
            }
        })
    }

    addPrePopTask(() => renameIO())
}

class SPIController(strHeader: PrintWriter,
                    spiDataWidth: Int,
                    enableDWORDDataAccess: Boolean,
                    toolType: SynthesisTool) extends Component{

    val io = new Bundle{
        val apb = slave(Apb3(addressWidth = 8, dataWidth = 32))
        val spiSCK = out Bool()
        val spiMOSI = out Bool()
        val spiCS = out Bool()
        val spiMISO = in Bool()
    }

    val clockFreq = ClockDomain.current.frequency.getValue

    val regControllerEnable = Reg(Bool()) init(False)
    val regPrescaler = Reg(UInt(log2Up(32) bits)) init(0)
    val regCS = Reg(Bool) init(True)
    val regFifoReset = Reg(Bool()) init(False)
    val regFifoWrEn = Reg(Bool())
    val regFifoRdEn = Bool()
    val regFifoDataIn = Reg(UInt(spiDataWidth bits))
    val regSkipTxReadback = Reg(Bool()) init(False)

    var fifoInOut = new Fifo(spiDataWidth, toolType)

    io.spiCS := regCS

    regFifoDataIn := 0
    regFifoWrEn := False
    regFifoRdEn := False
    // regSkipTxReadback := False

    fifoInOut.io.clk := ClockDomain.current.readClockWire
    fifoInOut.io.reset <> regFifoReset
    fifoInOut.io.writeEn <> regFifoWrEn
    fifoInOut.io.readEn <> regFifoRdEn
    fifoInOut.io.dataIn <> regFifoDataIn
    // val regFifoOutEmpty = RegNext(fifoInOut.io.empty) init(False)

    val apbCtrl = Apb3SlaveFactory(io.apb)
    val baseAddress = 0

    strHeader.println(f"#ifdef SPIController")
    strHeader.println()

    //create Control APB mapping to Fifo.reset and Enable
    val addrControlOffset = 0
    strHeader.println(f"${"#define SPI_CONTROL_REG"}%-30s((__IO uint32_t*)(SPICONTROLLER_BASE + 0x$addrControlOffset%02X))")
    apbCtrl.write(regPrescaler, baseAddress + addrControlOffset, 0, "PRESCALER")
    apbCtrl.write(regControllerEnable, baseAddress + addrControlOffset, regPrescaler.getWidth, "ENABLE")
    apbCtrl.write(regSkipTxReadback, baseAddress + addrControlOffset, regPrescaler.getWidth + 1, "TX_ONLY")
    apbCtrl.write(regCS, baseAddress + addrControlOffset, regPrescaler.getWidth + 2, "CS0")
    apbCtrl.write(regFifoReset, baseAddress + addrControlOffset, 16, "FIFO_RESET")
    
    apbCtrl.read(regControllerEnable, baseAddress + addrControlOffset, regPrescaler.getWidth, "IS_ENABLE")
    apbCtrl.read(regCS, baseAddress + addrControlOffset, regPrescaler.getWidth + 2, "CS0")
    apbCtrl.read(fifoInOut.io.full, baseAddress + addrControlOffset, 16, "FIFO_FULL")
    apbCtrl.read(fifoInOut.io.empty, baseAddress + addrControlOffset, 17, "FIFO_EMPTY")

    for(element <- apbCtrl.elementsPerAddress(bus.misc.SingleMapping(baseAddress + addrControlOffset)) if element.isInstanceOf[BusSlaveFactoryWrite]) {
        strHeader.println(f"${"#define CONTROL_WR_" + element.asInstanceOf[BusSlaveFactoryWrite].documentation + "_POS"}%-50s${element.asInstanceOf[BusSlaveFactoryWrite].bitOffset}")
        strHeader.println(f"${"#define CONTROL_WR_" + element.asInstanceOf[BusSlaveFactoryWrite].documentation + "_LEN"}%-50s${element.asInstanceOf[BusSlaveFactoryWrite].that.getBitsWidth}")
    }
    for(element <- apbCtrl.elementsPerAddress(bus.misc.SingleMapping(baseAddress + addrControlOffset)) if element.isInstanceOf[BusSlaveFactoryRead]) {
        strHeader.println(f"${"#define CONTROL_RD_" + element.asInstanceOf[BusSlaveFactoryRead].documentation + "_POS"}%-50s${element.asInstanceOf[BusSlaveFactoryRead].bitOffset}")
        strHeader.println(f"${"#define CONTROL_RD_" + element.asInstanceOf[BusSlaveFactoryRead].documentation + "_LEN"}%-50s${element.asInstanceOf[BusSlaveFactoryRead].that.getBitsWidth}")
    }
    strHeader.println()
    
    // //create Prescaler APB register variable
    // val addrPrescalerOffset = addrControlOffset + apbCtrl.wordAddressInc
    // strHeader.println(f"${"#define ws28xx_prescaler"}%-30s((__IO uint32_t*)(SPICONTROLLER_BASE + 0x$addrPrescalerOffset%02X))")
    // val apbPrescaler  = apbCtrl.createReadAndWrite(UInt(8 bits) ,baseAddress + addrPrescalerOffset,0)  init(0)
    // strHeader.println()
    
    //create Count APB register variable
    val addrCountOffset = addrControlOffset + apbCtrl.wordAddressInc
    strHeader.println(f"${"#define SPI_COUNT_REG"}%-30s((__IO uint32_t*)(SPICONTROLLER_BASE + 0x$addrCountOffset%02X))")
    val apbCountTx  = apbCtrl.createReadAndWrite(UInt(log2Up(1024+1) bits) ,baseAddress + addrCountOffset, 0, "COUNT_TX")  init(0)
    val apbCountRx  = apbCtrl.createReadAndWrite(UInt(log2Up(1024+1) bits) ,baseAddress + addrCountOffset, 16, "COUNT_RX")  init(0)
    for(element <- apbCtrl.elementsPerAddress(bus.misc.SingleMapping(baseAddress + addrCountOffset)) if element.isInstanceOf[BusSlaveFactoryWrite]) {
        strHeader.println(f"${"#define CONTROL_" + element.asInstanceOf[BusSlaveFactoryWrite].documentation + "_POS"}%-50s${element.asInstanceOf[BusSlaveFactoryWrite].bitOffset}")
        strHeader.println(f"${"#define CONTROL_" + element.asInstanceOf[BusSlaveFactoryWrite].documentation + "_LEN"}%-50s${element.asInstanceOf[BusSlaveFactoryWrite].that.getBitsWidth}")
    }
    strHeader.println()

    //create Data APB mapping to Fifo.dataIn
    val addrDataOffset = addrCountOffset + apbCtrl.wordAddressInc
    strHeader.println(f"${"#define SPI_DATA_REG"}%-30s((__IO uint32_t*)(SPICONTROLLER_BASE + 0x$addrDataOffset%02X))")
    apbCtrl.write(regFifoDataIn, baseAddress + addrDataOffset, 0)
    apbCtrl.onWrite(baseAddress + addrDataOffset) {
        regFifoWrEn := True
    }
    apbCtrl.read(fifoInOut.io.dataOut, baseAddress + addrDataOffset, 0)
    val regFifoDataOutRdy = RegNext(regFifoRdEn) init(False)
    apbCtrl.onReadPrimitive(bus.misc.SingleMapping(baseAddress + addrDataOffset), false, null) {
        apbCtrl.readHalt()
        regFifoRdEn.setWhen(io.apb.PREADY === False)    //generate fifo rd only for 1 cycle
        when(regFifoDataOutRdy === True) {
            io.apb.PREADY := True
        }
    }
    strHeader.println()
    
    //create 32bit DWORD Data access
    if (enableDWORDDataAccess) {
        val addrDataDwordOffset = addrDataOffset + apbCtrl.wordAddressInc
        val fifoPushPopCnt = Reg(UInt(log2Up(5) bits)) init(0)
        strHeader.println(f"${"#define SPI_DATADW_REG"}%-30s((__IO uint32_t*)(SPICONTROLLER_BASE + 0x$addrDataDwordOffset%02X))")
        // apbCtrl.write(fifoDataDWIn, baseAddress + addrDataDwordOffset, 0)
        val fifoDataDWIn = apbCtrl.nonStopWrite(UInt(32 bits), 0)
        apbCtrl.onWritePrimitive(bus.misc.SingleMapping(baseAddress + addrDataDwordOffset), false, null) {
            fifoPushPopCnt := fifoPushPopCnt + 1
            regFifoWrEn := True
            when(fifoPushPopCnt < 4) (apbCtrl.writeHalt())
            switch(fifoPushPopCnt) {
                is(0) (regFifoDataIn := fifoDataDWIn(0 to 7))
                is(1) (regFifoDataIn := fifoDataDWIn(8 to 15))
                is(2) (regFifoDataIn := fifoDataDWIn(16 to 23))
                is(3) (regFifoDataIn := fifoDataDWIn(24 to 31))
                default {
                    regFifoWrEn := False
                    fifoPushPopCnt := 0
                }
            }
        }

        val fifoDataDWOut = Reg(UInt(32 bits)) init(0)
        apbCtrl.read(fifoDataDWOut, baseAddress + addrDataDwordOffset, 0)
        apbCtrl.onReadPrimitive(bus.misc.SingleMapping(baseAddress + addrDataDwordOffset), false, null) {
            fifoPushPopCnt := fifoPushPopCnt + 1
            regFifoRdEn := True
            when(fifoPushPopCnt < 5) (apbCtrl.readHalt())
            switch(fifoPushPopCnt) {
                is(1) (fifoDataDWOut(0 to 7) := fifoInOut.io.dataOut)
                is(2) (fifoDataDWOut(8 to 15) := fifoInOut.io.dataOut)
                is(3) (fifoDataDWOut(16 to 23) := fifoInOut.io.dataOut)
                is(4) (fifoDataDWOut(24 to 31) := fifoInOut.io.dataOut)
                is(5) {
                    regFifoRdEn := False
                    fifoPushPopCnt := 0
                }
                default {}
            }
        }
        strHeader.println()
    }

    val ctrlLogic = new Area {
        val prescaleCounter = Reg(regPrescaler) init(0)
        val regSCK = Reg(Bool()) init(False)
        val regData = Reg(UInt(spiDataWidth bits))
        val spiDataShiftCounter = Reg(UInt(log2Up(spiDataWidth) bits)) init(spiDataWidth - 1)
        val regDataBit0 = Reg(Bool()) init(False)
        val shouldRdFifo = Bool()

        shouldRdFifo := False

        io.spiSCK <> regSCK
        io.spiMOSI <> regData(spiDataWidth - 1)

        val fsm = new StateMachine {
            val idle : State = new State with EntryPoint {
                whenIsActive {
                    when(regControllerEnable) {
                        shouldRdFifo := True
                        goto(fifoRd)
                    }
                }
            }

            val fifoRd : State = new StateDelay(cyclesCount = 2) {
                onEntry {
                    when(apbCountTx > 0) {
                        regFifoRdEn := shouldRdFifo
                    }
                    
                    // when(spiDataShiftCounter === 0) {
                    //     regSCK := False
                    //     // regData(1 until spiDataWidth) := regData(0 until spiDataWidth-1)
                    //     // regData(0) := regDataBit0
                    // }
                }
                
                whenCompleted {
                    when(apbCountTx > 0) {
                        regData := fifoInOut.io.dataOut
                        // regSkipTxReadback := regTxOnly
                        goto(clockLow)
                    } elsewhen(apbCountRx > 0) {
                        regData := regData.maxValue
                        regSkipTxReadback := False
                        goto(clockLow)
                    } otherwise {
                        regControllerEnable := False
                        exit()
                    }
                    
                    when(spiDataShiftCounter === 0 && regSkipTxReadback === False) {
                        regFifoDataIn := regData
                        regFifoWrEn := True
                    }
                }
                onExit (spiDataShiftCounter := spiDataWidth - 1)
            }

            val clockLow : State = new State {
                onEntry {
                    prescaleCounter := 0
                    regSCK := False
                }

                whenIsActive {
                    when(prescaleCounter === regPrescaler) {
                        regDataBit0 := io.spiMISO
                        goto(clockHigh)
                    }
                    prescaleCounter := prescaleCounter + 1
                }
            }
            
            val clockHigh : State = new State {
                onEntry {
                    prescaleCounter := 0
                    regSCK := True
                }

                whenIsActive {
                    when(prescaleCounter === regPrescaler) {
                        
                        regData(1 until spiDataWidth) := regData(0 until spiDataWidth-1)
                        regData(0) := regDataBit0

                        when(spiDataShiftCounter > 0) {
                            spiDataShiftCounter := spiDataShiftCounter - 1
                            // regData := regData |<< 1
                            goto(clockLow)
                        }

                        when(spiDataShiftCounter === 0) {
                            when(apbCountTx > 0) (apbCountTx := apbCountTx - 1)
                            when(apbCountRx > 0) (apbCountRx := apbCountRx - 1)
                            regSCK := False
                            when(apbCountTx === 1) {
                                shouldRdFifo := False
                            } otherwise {
                                shouldRdFifo := True
                            }
                            goto(fifoRd)

                            // when(apbCountTx > 1) {
                            //     regFifoRdEn := True
                            //     goto(clockLow)
                            // }

                            // when(apbCountTx < 1) {
                            //     goto(idle)
                            // }
                        }
                    }
                    prescaleCounter := prescaleCounter + 1
                }
            }
        }

        // prescaleCounter := prescaleCounter + 1
        // when(regControllerEnable && apbCountTx > 0 && prescaleCounter === regPrescaler) {
        //     prescaleCounter := 0
        //     regSCK := !regSCK
            
        //     when(regSCK === True) {
        //         spiDataShiftCounter := spiDataShiftCounter - 1
        //         // regData := regData |<< 1
        //         regData(1 until spiDataWidth) := regData(0 until spiDataWidth-1)

        //         when(spiDataShiftCounter === 0) {
        //             spiDataShiftCounter := spiDataWidth - 1
        //             apbCountTx := apbCountTx - 1

        //             regFifoDataIn := regData
        //             regFifoWrEn := True
        //         }
        //     }

        //     when(regSCK === False) {
        //         regDataBit0 := io.spiMISO
        //         regData(0) := regDataBit0
        //     }
        // }

        // regControllerEnable.clearWhen(apbCountTx === 0)

        // when(regControllerEnable && apbCountTx > 0 && spiDataShiftCounter === spiDataWidth-1 && regSCK === False && ClockDomain.current.readClockWire) {
        //     regFifoRdEn := True
        // }
        // when(regFifoDataOutRdy) {
        //     regData := fifoInOut.io.dataOut
        // }
    }

    // apbCtrl.onWrite(baseAddress + addrControlOffset) {
    //     ctrlLogic.prescaleCounter := 0
    //     ctrlLogic.spiDataShiftCounter := spiDataWidth - 1
    // }

    strHeader.println("#endif")
}

object Top {
    val clkFreq:HertzNumber = 72 MHz
    def main(args: Array[String]):Unit = {
        val targetDirectory = "out"
        val strHeader = new PrintWriter(targetDirectory + "/SPIController.h")
        SpinalConfig(mode = Verilog,
                    targetDirectory = targetDirectory,
                    defaultClockDomainFrequency = FixedFrequency(clkFreq),
                    defaultConfigForClockDomains = ClockDomainConfig(resetActiveLevel = LOW)
                    ).generate(new SPIController(strHeader, 8, enableDWORDDataAccess = true, Vivado)).printPruned()

        strHeader.close()
    }
}
