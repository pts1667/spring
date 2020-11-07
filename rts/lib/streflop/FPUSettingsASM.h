/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */

#if defined(_MSC_VER)
extern "C"
{
  extern void _streflop_fstcw(short *tmp);
  extern void _streflop_fldcw(short *tmp);
  extern void _streflop_stmxcsr(int *tmp);
  extern void _streflop_ldmxcsr(int *tmp);
}
#endif