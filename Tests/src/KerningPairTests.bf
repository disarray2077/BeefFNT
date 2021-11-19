//**************************************************************************************************
// BitmapFontCommonTests.bf                                                                        *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;

namespace BeefFNT.Tests
{
	static class KerningPairTests
	{
		[Test]
		public static void KerningPairToString()
		{
		    var kerningPair = KerningPair(5, 2);
		    Assert.AreEqual("First: 5, Second: 2", kerningPair.ToString(.. scope .()));
		}

		[Test]
		public static void KerningPairEqualOp()
		{
		    var one = KerningPair(6, 4);
		    var two = KerningPair(6, 4);
		    Assert.IsTrue(one == two);
		}

		[Test]
		public static void KerningPairInequalityOp()
		{
		    var one = KerningPair(6, 4);
		    var two = KerningPair(7, 3);
		    Assert.IsTrue(one != two);
		}
	}
}
