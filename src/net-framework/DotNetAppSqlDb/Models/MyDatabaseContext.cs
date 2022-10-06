using Azure.Identity;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace DotNetAppSqlDb.Models
{
    public class MyDatabaseContext : DbContext
    {
        // You can add custom code to this file. Changes will not be overwritten.
        // 
        // If you want Entity Framework to drop and regenerate your database
        // automatically whenever you change your model schema, please use data migrations.
        // For more information refer to the documentation:
        // http://msdn.microsoft.com/en-us/data/jj591621.aspx
    
        public MyDatabaseContext() : base("name=MyDbConnection")
        {
            if (ConfigurationManager.AppSettings["UseManagedIdentity"] == "true")
            {
                var conn = (System.Data.SqlClient.SqlConnection)Database.Connection;
                var credential = new Azure.Identity.DefaultAzureCredential(new DefaultAzureCredentialOptions { ManagedIdentityClientId = ConfigurationManager.AppSettings["ManagedIdentityClientId"] });
                var token = credential.GetToken(new Azure.Core.TokenRequestContext(new[] { "https://database.windows.net/.default" }));
                conn.AccessToken = token.Token;
            }
        }

        public System.Data.Entity.DbSet<DotNetAppSqlDb.Models.Todo> Todoes { get; set; }
    }
}
