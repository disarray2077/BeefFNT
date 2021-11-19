using System;
using System.IO;

namespace BeefFNT
{
	static
	{
		internal static Result<void> WriteLine(this StreamWriter self)
		{
			return self.Write("\n");
		}
	}
}
