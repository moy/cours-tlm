#ifndef MEMORY_H_OFFSETS
#define MEMORY_H_OFFSETS

#define ALIGN(addr)				\
	((addr) & (-sizeof(uint32_t)))

#define BIT(bit)				\
	(1 << (bit))

#define TEST_BIT(var, bit)			\
	((var) & BIT(bit))

#define SET_BIT(var, bit)			\
	do { (var) |= BIT(bit); } while(0)

#define CLEAR_BIT(var, bit)			\
	do { (var) &= ~BIT(bit); } while(0)

#endif
