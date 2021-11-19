//**************************************************************************************************
// BitmapFontCommonTests.bf                                                                        *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.Collections;

namespace BeefFNT.Tests
{
	static class TextFormatUtilityTests
	{
		[Test]
		public static void ReadInvalidValue()
		{
		    var segments = scope List<StringView>()
		    {
		        "This is not a valid property.", "This is also not a valid property."
		    };

		    Assert.AreEqual(default(StringView), TextFormatUtility.ReadValue("Test", segments));
		}

		[Test(ShouldFail=true)]
		public static void ReadInvalidBool()
		{
		    var segments = scope List<StringView>()
		    {
		        "Test=2"
		    };

		    TextFormatUtility.ReadBool("Test", segments);
		}

		[Test]
		public static void ReadMissingBool()
		{
		    var segments = scope List<StringView>();
		    Assert.AreEqual(false, TextFormatUtility.ReadBool("Test", segments));
		}

		[Test(ShouldFail=true)]
		public static void ReadInvalidEnum()
		{
		    var segments = scope List<StringView>()
		    {
		        "Test=abacate"
		    };

		    TextFormatUtility.ReadEnum<StringSplitOptions>("Test", segments);
		}

		[Test]
		public static void ReadString()
		{
		    var segments = scope List<StringView>()
		    {
		        "Test=abacate"
		    };

		    Assert.AreEqual("abacate", TextFormatUtility.ReadString("Test", segments));
		}
	}
}
