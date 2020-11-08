/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */

#if defined(_MSC_VER)
extern "C"
{
  extern unsigned short _streflop_fstcw();
  extern void _streflop_fldcw(unsigned short tmp);
}
#endif