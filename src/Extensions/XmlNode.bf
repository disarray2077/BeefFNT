using System;
using System.Collections;
using Xml_Beef;

using internal BeefFNT;

namespace BeefFNT
{
	static
	{
		internal static XmlNode SetAttribute<T>(this XmlNode self, String name, T val)
			where T : var
		{
			return self.SetAttribute(name, val.ToString(.. scope String()));
		}

		internal static XmlNodeEnumerator EnumNodes(this XmlNode self, String name, XmlNodeType types = .Element)
		{
			return XmlNodeEnumerator(self.ChildNodes, name, types);
		}

		internal struct XmlNodeEnumerator : IEnumerator<XmlNode>, IRefEnumerator<XmlNode*>, IResettable
		{
			private List<XmlNode> mList;
			private int mIndex;
#if VERSION_LIST
			private int32 mVersion;
#endif
			private XmlNode* mCurrent;
			private String mName;
			private XmlNodeType mTypes;

			public this(List<XmlNode> list, String name, XmlNodeType types)
			{
			    mList = list;
			    mIndex = 0;
#if VERSION_LIST
			    mVersion = list.[Friend]mVersion;
#endif
			    mCurrent = null;
				mName = name;
				mTypes = types;
			}

#if VERSION_LIST
			void CheckVersion()
			{
				if (mVersion != mList.[Friend]mVersion)
					Runtime.FatalError(cVersionError);
			}
#endif

			public void Dispose()
			{
			}

			public bool MoveNext() mut
			{
			    List<XmlNode> localList = mList;
			    while ((uint(mIndex) < uint(localList.[Friend]mSize)))
			    {
			        var current = ref localList.[Friend]mItems[mIndex];
			        mIndex++;

					if ((mTypes == .None || mTypes.HasFlag(current.NodeType)) && mName.Equals(current.Name, .OrdinalIgnoreCase))
					{
						mCurrent = &current;
			        	return true;
					}
			    }	   
			    return MoveNextRare();
			}

			private bool MoveNextRare() mut
			{
#if VERSION_LIST
				CheckVersion();
#endif
				mIndex = mList.[Friend]mSize + 1;
			    mCurrent = null;
			    return false;
			}

			public XmlNode Current
			{
			    get
			    {
			        return *mCurrent;
			    }

				set
				{
					*mCurrent = value;
				}
			}

			public ref XmlNode CurrentRef
			{
			    get
			    {
			        return ref *mCurrent;
			    }
			}

			public int Index
			{
				get
				{
					return mIndex - 1;
				}				
			}

			public int Count
			{
				get
				{
					return mList.Count;
				}				
			}

			public void Remove() mut
			{
				int curIdx = mIndex - 1;
				mList.RemoveAt(curIdx);
#if VERSION_LIST
				mVersion = mList.mVersion;
#endif
				mIndex = curIdx;
			}

			public void RemoveFast() mut
			{
				int curIdx = mIndex - 1;
				int lastIdx = mList.Count - 1;
				if (curIdx < lastIdx)
			        mList[curIdx] = mList[lastIdx];
				mList.RemoveAt(lastIdx);
#if VERSION_LIST
				mVersion = mList.mVersion;
#endif
				mIndex = curIdx;
			}

			public void Reset() mut
			{
			    mIndex = 0;
			    mCurrent = null;
			}

			public Result<XmlNode> GetNext() mut
			{
				if (!MoveNext())
					return .Err;
				return Current;
			}

			public Result<XmlNode*> GetNextRef() mut
			{
				if (!MoveNext())
					return .Err;
				return &CurrentRef;
			}
		}
	}
}
