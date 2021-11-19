//**************************************************************************************************
// UtilityExtensions.bf                                                                            *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using System.IO;

namespace BeefFNT
{
    static
    {
        internal static Result<void> ReadNullTerminatedString(this Stream stream, String outString)
        {
            while (true)
            {
                let character = Try!(stream.Read<uint8>());

                if (character == 0)
                {
                    break;
                }

                outString.Append((char16)character);
            }

			return .Ok;
        }

        internal static Result<void> WriteNullTerminatedString(this Stream stream, String value)
        {
            if (value != null)
            {
                for (let character in value.RawChars)
                {
                    Try!(stream.Write(character));
                }
            }

            Try!(stream.Write((uint8)0));
			return .Ok;
        }

		internal static Result<void> WriteNullTerminatedString(this Stream stream, StringView value)
		{
		    if (value.Ptr != null)
		    {
		        for (let character in value.RawChars)
		        {
		            Try!(stream.Write(character));
		        }
		    }

		    Try!(stream.Write((uint8)0));
			return .Ok;
		}
    }
}