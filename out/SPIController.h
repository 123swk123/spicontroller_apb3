#ifdef SPIController

#define SPI_CONTROL_REG       ((__IO uint32_t*)(SPICONTROLLER_BASE + 0x00))
#define CONTROL_WR_PRESCALER_POS                  0
#define CONTROL_WR_PRESCALER_LEN                  5
#define CONTROL_WR_ENABLE_POS                     5
#define CONTROL_WR_ENABLE_LEN                     1
#define CONTROL_WR_TX_ONLY_POS                    6
#define CONTROL_WR_TX_ONLY_LEN                    1
#define CONTROL_WR_CS0_POS                        7
#define CONTROL_WR_CS0_LEN                        1
#define CONTROL_WR_FIFO_RESET_POS                 16
#define CONTROL_WR_FIFO_RESET_LEN                 1
#define CONTROL_RD_IS_ENABLE_POS                  5
#define CONTROL_RD_IS_ENABLE_LEN                  1
#define CONTROL_RD_CS0_POS                        7
#define CONTROL_RD_CS0_LEN                        1
#define CONTROL_RD_FIFO_FULL_POS                  16
#define CONTROL_RD_FIFO_FULL_LEN                  1
#define CONTROL_RD_FIFO_EMPTY_POS                 17
#define CONTROL_RD_FIFO_EMPTY_LEN                 1

#define SPI_COUNT_REG         ((__IO uint32_t*)(SPICONTROLLER_BASE + 0x04))
#define CONTROL_COUNT_TX_POS                      0
#define CONTROL_COUNT_TX_LEN                      11
#define CONTROL_COUNT_RX_POS                      16
#define CONTROL_COUNT_RX_LEN                      11

#define SPI_DATA_REG          ((__IO uint32_t*)(SPICONTROLLER_BASE + 0x08))

#define SPI_DATADW_REG        ((__IO uint32_t*)(SPICONTROLLER_BASE + 0x0C))

#endif
