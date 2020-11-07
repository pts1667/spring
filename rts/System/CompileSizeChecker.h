/* This file is part of the Spring engine (GPL v2 or later), see LICENSE.html */

#ifndef _COMPILE_SIZE_CHECKER_H_
#define _COMPILE_SIZE_CHECKER_H_

// displays the sizes in error log. Useful for shitty IDEs.
template <typename S1, typename S2, size_t szS1 = sizeof(S1), size_t szS2 = sizeof(S2)>
struct CompileSizeChecker
{
  static constexpr void MustBeLessThan() { static_assert(szS1 <= szS2, "bad sizes, S1 must be smaller than S2"); }
  static constexpr void MustBeGreaterThan() { static_assert(szS1 >= szS2, "bad sizes, S1 must be bigger than S2"); }
  static constexpr void MustBeStrictlyLessThan() { static_assert(szS1 < szS2, "bad sizes, S1 must be strictly smaller than S2"); }
  static constexpr void MustBeStrictlyGreaterThan() { static_assert(szS1 > szS2, "bad sizes, S1 must be strictly bigger than S2"); }
};

#endif