//**************************************************************************************************
// UtilityExtensions.bf                                                                            *
// Copyright (c) 2018-2020 Aurora Berta-Oldham                                                     *
// Copyright (c) 2020 disarray                                                                     *
// This code is made available under the MIT License.                                              *
//**************************************************************************************************

using System;
using Xml_Beef;

namespace BeefFNT
{
    static
    {
        internal static Result<T> GetEnumValue<T>(this XmlAttribute xAttribute) where T : Enum
        {
            return Enum.Parse<T>(xAttribute.Value);
        }
    }
}