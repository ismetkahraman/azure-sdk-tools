﻿// ----------------------------------------------------------------------------------
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------

namespace Microsoft.WindowsAzure.Management.SqlDatabase.Services
{
    using System.Runtime.Serialization;

    /// <summary>
    /// New database data contract
    /// </summary>
    [DataContract(Name = "ServiceResource", Namespace = Constants.ServiceManagementNamespace)]
    public class SqlDatabaseInput : IExtensibleDataObject
    {
        [DataMember(Order = 1, EmitDefaultValue = false)]
        public string Name { get; set; }

        [DataMember(Order = 2, EmitDefaultValue = false)]
        public string Id { get; set; }

        [DataMember(Order = 3, EmitDefaultValue = false)]
        public string Edition { get; set; }

        [DataMember(Order = 4, EmitDefaultValue = false)]
        public string MaxSizeGB { get; set; }

        [DataMember(Order = 5, EmitDefaultValue = false)]
        public string CollationName { get; set; }


        public ExtensionDataObject ExtensionData { get; set; }
    }
}
