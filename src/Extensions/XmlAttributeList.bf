using System;
using Xml_Beef;

namespace BeefFNT
{
	static
	{
		internal static T GetValueOrDefault<T>(this XmlAttributeList self, String name)
			where T : String
		{
			if ((let attr = self.Find(name)) && attr != null)
				return attr.Value;
			return default(T);
		}

		internal static T GetValueOrDefault<T>(this XmlAttributeList self, String name)
			where T : Boolean
		{
			if ((let attr = self.Find(name)) && attr != null)
				return (T)(attr.Value == "1");
			return default(T);
		}

		internal static T GetValueOrDefault<T>(this XmlAttributeList self, String name)
			where T : INumeric
		{
			return GetValueOrDefaultImpl<T>(self, name);
		}

		internal static T GetValueOrDefaultImpl<T>(XmlAttributeList self, String name)
			where T : Enum
		{
			if ((let attr = self.Find(name)) && attr != null)
				return (T)int.Parse(attr.Value).GetValueOrDefault();
			return default(T);
		}

		internal static T GetValueOrDefaultImpl<T>(XmlAttributeList self, String name)
			where T : var
		{
			if ((let attr = self.Find(name)) && attr != null)
				return T.Parse(attr.Value).GetValueOrDefault();
			return default(T);
		}
	}
}
