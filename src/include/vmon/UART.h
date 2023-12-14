#ifndef VMON_UART_H
#define VMON_UART_H
#define UART_BASE		0x10000000
#define UART_REG_IER	0x02
#define UART_IRQ_ON		0b00000001
#define UART_REG_LSR	0x03
#define UART_MODE_8N1   0b00000011

#endif /* VMON_UART_H */