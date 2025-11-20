using System;
using System.Data.Entity;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using WebApplication1.Models;

namespace WebApplication1
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Configure database to recreate when model changes
            Database.SetInitializer<ApplicationDbContext>(new DropCreateDatabaseIfModelChanges<ApplicationDbContext>());

            // Create default roles and admin user
            CreateRolesAndDefaultUsers();
        }

        private void CreateRolesAndDefaultUsers()
        {
            using (var context = new ApplicationDbContext())
            {
                // Ensure database is created
                context.Database.Initialize(force: false);
                
                // Create application tables
                CreateApplicationTables(context);

                var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(context));
                var userManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));

                // Create Admin role + default admin user
                if (!roleManager.RoleExists("Admin"))
                {
                    roleManager.Create(new IdentityRole("Admin"));

                    var adminUser = new ApplicationUser
                    {
                        UserName = "admin@petsupply.com",
                        Email = "admin@petsupply.com",
                        DisplayName = "Administrator"
                    };

                    var check = userManager.Create(adminUser, "Admin@123");
                    if (check.Succeeded)
                    {
                        userManager.AddToRole(adminUser.Id, "Admin");
                    }
                }

                // Create Seller role
                if (!roleManager.RoleExists("Seller"))
                {
                    roleManager.Create(new IdentityRole("Seller"));
                }
                
                // Create Customer role
                if (!roleManager.RoleExists("Customer"))
                {
                    roleManager.Create(new IdentityRole("Customer"));
                }
            }
        }

        private void CreateApplicationTables(ApplicationDbContext context)
        {
            try
            {
                var connStr = context.Database.Connection.ConnectionString;
                using (var conn = new System.Data.SqlClient.SqlConnection(connStr))
                {
                    conn.Open();
                    
                    // Create PetSupplies table
                    string createPetSuppliesTable = @"
                        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PetSupplies]') AND type in (N'U'))
                        BEGIN
                            CREATE TABLE [dbo].[PetSupplies](
                                [Id] [int] IDENTITY(1,1) NOT NULL,
                                [Name] [nvarchar](200) NOT NULL,
                                [Description] [nvarchar](1000) NULL,
                                [Price] [decimal](18, 2) NOT NULL,
                                [ImageUrl] [nvarchar](500) NULL,
                                [Category] [nvarchar](100) NULL,
                                [SellerId] [nvarchar](128) NOT NULL,
                                [SellerName] [nvarchar](100) NOT NULL,
                                [Status] [nvarchar](50) NOT NULL DEFAULT 'Pending',
                                [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
                                [Stock] [int] NOT NULL DEFAULT 0,
                                [StockStatus] [nvarchar](20) NOT NULL DEFAULT 'In Stock',
                                CONSTRAINT [PK_PetSupplies] PRIMARY KEY CLUSTERED ([Id] ASC)
                            )
                        END";

                    using (var cmd = new System.Data.SqlClient.SqlCommand(createPetSuppliesTable, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Create Orders table
                    string createOrdersTable = @"
                        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND type in (N'U'))
                        BEGIN
                            CREATE TABLE [dbo].[Orders](
                                [OrderId] [int] IDENTITY(1,1) NOT NULL,
                                [CustomerId] [nvarchar](128) NOT NULL,
                                [CustomerName] [nvarchar](100) NOT NULL,
                                [Address] [nvarchar](500) NOT NULL,
                                [Phone] [nvarchar](15) NOT NULL,
                                [Email] [nvarchar](100) NULL,
                                [PaymentMethod] [nvarchar](50) NOT NULL,
                                [TotalAmount] [decimal](18, 2) NOT NULL,
                                [OrderDate] [datetime] NOT NULL,
                                [Status] [nvarchar](50) NOT NULL,
                                CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderId] ASC),
                                CONSTRAINT [FK_Orders_AspNetUsers] FOREIGN KEY([CustomerId]) 
                                    REFERENCES [dbo].[AspNetUsers] ([Id])
                            )
                        END";

                    using (var cmd = new System.Data.SqlClient.SqlCommand(createOrdersTable, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Create OrderItems table
                    string createOrderItemsTable = @"
                        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OrderItems]') AND type in (N'U'))
                        BEGIN
                            CREATE TABLE [dbo].[OrderItems](
                                [OrderItemId] [int] IDENTITY(1,1) NOT NULL,
                                [OrderId] [int] NOT NULL,
                                [ProductId] [int] NOT NULL,
                                [ProductName] [nvarchar](200) NOT NULL,
                                [Quantity] [int] NOT NULL,
                                [Price] [decimal](18, 2) NOT NULL,
                                CONSTRAINT [PK_OrderItems] PRIMARY KEY CLUSTERED ([OrderItemId] ASC),
                                CONSTRAINT [FK_OrderItems_Orders] FOREIGN KEY([OrderId]) 
                                    REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE,
                                CONSTRAINT [FK_OrderItems_PetSupplies] FOREIGN KEY([ProductId]) 
                                    REFERENCES [dbo].[PetSupplies] ([Id])
                            )
                        END";

                    using (var cmd = new System.Data.SqlClient.SqlCommand(createOrderItemsTable, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Create indexes for better performance
                    string createIndexes = @"
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_OrderDate' AND object_id = OBJECT_ID('Orders'))
                        BEGIN
                            CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate] ON [dbo].[Orders]([OrderDate] DESC)
                        END
                        
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_CustomerId' AND object_id = OBJECT_ID('Orders'))
                        BEGIN
                            CREATE NONCLUSTERED INDEX [IX_Orders_CustomerId] ON [dbo].[Orders]([CustomerId] ASC)
                        END
                        
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_OrderId' AND object_id = OBJECT_ID('OrderItems'))
                        BEGIN
                            CREATE NONCLUSTERED INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems]([OrderId] ASC)
                        END
                        
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_ProductId' AND object_id = OBJECT_ID('OrderItems'))
                        BEGIN
                            CREATE NONCLUSTERED INDEX [IX_OrderItems_ProductId] ON [dbo].[OrderItems]([ProductId] ASC)
                        END";

                    using (var cmd = new System.Data.SqlClient.SqlCommand(createIndexes, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't stop application startup
                System.Diagnostics.Trace.TraceError($"Error creating application tables: {ex.Message}");
            }
        }
    }
}