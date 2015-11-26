/********************************************************************
 * Copyright (C) 2009, 2012 by Verimag                              *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

/*!
  \file hal.h
  \brief Hardware Abstraction Layer : implementation for native
  simulation in SystemC.


*/
#ifndef HAL_H
#define HAL_H

#include <stdint.h>

/* fonctions déclarées ici, et implémentées dans native_wrapper.cpp */
extern void write_mem(uint32_t addr, uint32_t data);
extern uint32_t read_mem(uint32_t addr);
extern void cpu_relax();
extern void wait_for_irq();

#endif /* HAL_H */
