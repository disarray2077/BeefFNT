//**************************************************************************************************
// BitmapFontCommonTests.bf                                                                        *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;

using internal BeefFNT;

namespace BeefFNT.Tests
{
	static class UtilityExtensionTests
	{
		[Test]
		public static void ReadBit()
		{
		    const uint8 testNumber = 0b0010000;
		    Assert.IsTrue(testNumber.IsBitSet(4));
		}

		[Test]
		public static void WriteBitTrue()
		{
		    const uint8 expected = 0b0100;
		    uint8 value = 0;
		    value = value.SetBit(2, true);
		    Assert.AreEqual(expected, value);
		}

		[Test]
		public static void WriteBitFalse()
		{
		    const uint8 expected = 0b01111111;
		    uint8 value = 0b11111111;
		    value = value.SetBit(7, false);
		    Assert.AreEqual(expected, value);
		}

		[Test(ShouldFail=true)]
		public static void WriteBitOutOfRange()
		{
		    const uint8 value = 0;
		    value.SetBit(int.MaxValue, true);
		}

		[Test(ShouldFail=true)]
		public static void ReadBitOutOfRange()
		{
		    const uint8 value = 0;
		    value.IsBitSet(int.MaxValue);
		}
	}
}
