using System;

namespace BeefFNT
{
	static
	{
		internal static bool Equals(this String self, StringView str)
		{
			return str.Equals(self);
		}

		internal static bool Equals(this String self, StringView str, bool ignoreCase = false)
		{
			return str.Equals(self, ignoreCase);
		}
	}
}
