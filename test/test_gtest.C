// SPDX-FileCopyrightText: 2023 SAP SE
//
// SPDX-License-Identifier: Apache-2.0
//
// This file is part of FEDEM - https://openfedem.org
////////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include "gtest/gtest.h"


TEST(TestCmake,Hello)
{
  std::cout <<"Hello, world"<< std::endl;
  double a = 2.0;
  double b = 3.5;
  double c = a + b;
  ASSERT_EQ(c,5.5);
}
