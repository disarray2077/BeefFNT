using System;

namespace BeefFNT.Tests
{
	public static class Assert
	{
		public static void IsTrue(bool val) => Test.Assert(val);
		public static void IsTrue(bool val, String error) => Test.Assert(val, error);
		public static void IsFalse(bool val) => Test.Assert(!val);
		public static void IsFalse(bool val, String error) => Test.Assert(!val, error);
		public static void AreEqual<T1, T2>(T1 lhs, T2 rhs) where bool : operator T1 == T2 { Test.Assert(lhs == rhs); }
		public static void AreEqual<T1, T2>(T1 lhs, T2 rhs, String error) where bool : operator T1 == T2 { Test.Assert(lhs == rhs, error); }
		public static void Fail(String error) => Test.FatalError(error);
	}
}
