//**************************************************************************************************
// BitmapFontCommonTests.bf                                                                        *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.IO;

namespace BeefFNT.Tests
{
	static class BitmapFontCommonTests
	{
		[Test(ShouldFail=true)]
		public static void ReadBinaryWrongBlockSize()
		{
		    var memoryStream = new MemoryStream();
            memoryStream.Write<int32>(8);
            memoryStream.Write<int32>(2);
            memoryStream.Write<int32>(1);

	        memoryStream.Seek(0);

	        BitmapFontCommon.ReadBinary(memoryStream, ?);
		}
	}
}
