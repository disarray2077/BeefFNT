using System;
using System.IO;

namespace BeefFNT
{
	static
	{
		internal static Result<char8> Peek(this StreamReader self)
		{
			if (self.[Friend]mStream == null)
				return .Err;
			if (self.[Friend]mCharPos == self.[Friend]mCharLen)
			{
				if (Try!(self.[Friend]ReadBuffer()) == 0) return .Err;
			}
			return self.[Friend]mCharBuffer[self.[Friend]mCharPos];
		}
	}
}
