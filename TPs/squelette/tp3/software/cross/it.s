/*\
 * This file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MutekH; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author: Frédéric Pétrot <Frederic.Petrot@imag.fr>
 *
 * Interrupt handling:
 * Context saving : I don't have the Mutek version at hand (travelling
 * to Canada), so I do it the easy way
 * I assume that the stack is pointed to by r1 as usual for pure
 * kernel mode stuff
\*/
   .globl  __interrupt_handler
   .ent    __interrupt_handler

   .text
__interrupt_handler:
   /*\ Registers not to be saved :
    *  r0, r1 and r2 are not supposed to be changed by anything called
    *  from here, and ear, esr and fsr are not concerned by interrupt,
    *  as far as I can say
    *  This leaves out 30 registers in the context
   \*/
   addik r1,  r1, -4 * 30
   swi   r3,  r1, 4 * 0
   swi   r4,  r1, 4 * 1
   swi   r5,  r1, 4 * 2
   swi   r6,  r1, 4 * 3
   swi   r7,  r1, 4 * 4
   swi   r8,  r1, 4 * 5
   swi   r9,  r1, 4 * 6
   swi   r10, r1, 4 * 7
   swi   r11, r1, 4 * 8
   swi   r12, r1, 4 * 9
   swi   r13, r1, 4 * 10
   swi   r14, r1, 4 * 11
   swi   r15, r1, 4 * 12
   swi   r16, r1, 4 * 13
   swi   r17, r1, 4 * 14
   swi   r18, r1, 4 * 15
   swi   r19, r1, 4 * 16
   swi   r20, r1, 4 * 17
   swi   r21, r1, 4 * 18
   swi   r22, r1, 4 * 19
   swi   r23, r1, 4 * 20
   swi   r24, r1, 4 * 21
   swi   r25, r1, 4 * 22
   swi   r26, r1, 4 * 23
   swi   r27, r1, 4 * 24
   swi   r28, r1, 4 * 25
   swi   r29, r1, 4 * 26
   swi   r30, r1, 4 * 27
   swi   r31, r1, 4 * 28
   mfs   r3,  rmsr
   swi   r3,  r1, 4 * 29

   bralid r15, interrupt_handler
   /*\
    * Because we shall not have here an instruction that can
    * generate an exception (a sw can), I have nothing interesting to do
    * in this delay slot
    */
   nop

   lwi   r3,  r1, 4 * 29
   mts   rmsr,  r3
   lwi   r3,  r1, 4 * 0
   lwi   r4,  r1, 4 * 1
   lwi   r5,  r1, 4 * 2
   lwi   r6,  r1, 4 * 3
   lwi   r7,  r1, 4 * 4
   lwi   r8,  r1, 4 * 5
   lwi   r9,  r1, 4 * 6
   lwi   r10, r1, 4 * 7
   lwi   r11, r1, 4 * 8
   lwi   r12, r1, 4 * 9
   lwi   r13, r1, 4 * 10
   lwi   r14, r1, 4 * 11
   lwi   r15, r1, 4 * 12
   lwi   r16, r1, 4 * 13
   lwi   r17, r1, 4 * 14
   lwi   r18, r1, 4 * 15
   lwi   r19, r1, 4 * 16
   lwi   r20, r1, 4 * 17
   lwi   r21, r1, 4 * 18
   lwi   r22, r1, 4 * 19
   lwi   r23, r1, 4 * 20
   lwi   r24, r1, 4 * 21
   lwi   r25, r1, 4 * 22
   lwi   r26, r1, 4 * 23
   lwi   r27, r1, 4 * 24
   lwi   r28, r1, 4 * 25
   lwi   r29, r1, 4 * 26
   lwi   r30, r1, 4 * 27
   lwi   r31, r1, 4 * 28
   rtid  r14, 0
   addik r1,  r1, 4 * 30
   .end __interrupt
