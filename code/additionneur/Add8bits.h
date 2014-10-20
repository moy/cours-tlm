#include "systemc.h"

SC_MODULE(Add8bits)
{
   sc_in<sc_uint<8> > a, b;
   sc_out<sc_uint<8> > c;
   
   SC_CTOR(Add8bits);
  
   void calcul();
};