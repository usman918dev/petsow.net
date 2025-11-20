using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace WebApplication1
{
    public partial class SetupDatabase : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSetupDatabase_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
                StringBuilder result = new StringBuilder();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

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
                        END
                        ELSE
                        BEGIN
                            -- Check if CustomerId column exists, if not add it
                            IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'CustomerId')
                            BEGIN
                                ALTER TABLE [dbo].[Orders]
                                ADD [CustomerId] [nvarchar](128) NULL
                                
                                -- Add foreign key constraint
                                ALTER TABLE [dbo].[Orders]
                                ADD CONSTRAINT [FK_Orders_AspNetUsers] FOREIGN KEY([CustomerId]) 
                                    REFERENCES [dbo].[AspNetUsers] ([Id])
                            END
                        END";

                    using (SqlCommand cmd = new SqlCommand(createOrdersTable, conn))
                    {
                        cmd.ExecuteNonQuery();
                        result.AppendLine("? Orders table created/updated successfully (with CustomerId).");
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
                                    REFERENCES [dbo].[Orders] ([OrderId]) ON DELETE CASCADE
                            )
                        END";

                    using (SqlCommand cmd = new SqlCommand(createOrderItemsTable, conn))
                    {
                        cmd.ExecuteNonQuery();
                        result.AppendLine("? OrderItems table created successfully.");
                    }

                    // Add Stock columns to PetSupplies if they don't exist
                    string addStockColumns = @"
                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PetSupplies') AND name = 'Stock')
                        BEGIN
                            ALTER TABLE PetSupplies ADD Stock INT NOT NULL DEFAULT 0
                        END
                        
                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('PetSupplies') AND name = 'StockStatus')
                        BEGIN
                            ALTER TABLE PetSupplies ADD StockStatus NVARCHAR(20) NOT NULL DEFAULT 'In Stock'
                        END";

                    using (SqlCommand cmd = new SqlCommand(addStockColumns, conn))
                    {
                        cmd.ExecuteNonQuery();
                        result.AppendLine("? Stock columns added to PetSupplies table.");
                    }

                    // Create indexes
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
                        END";

                    using (SqlCommand cmd = new SqlCommand(createIndexes, conn))
                    {
                        cmd.ExecuteNonQuery();
                        result.AppendLine("? Indexes created successfully.");
                    }

                    result.AppendLine("<br/><strong>Database setup completed successfully!</strong>");
                    result.AppendLine("<br/>You can now use the e-commerce functionality.");
                    result.AppendLine("<br/><br/><strong>Note:</strong> Orders table now includes CustomerId linked to user accounts.");
                    result.AppendLine("<br/><strong>Note:</strong> PetSupplies table now includes Stock and StockStatus columns.");

                    ShowResult(result.ToString(), "alert alert-success result-box");
                }
            }
            catch (Exception ex)
            {
                string errorMsg = $"<strong>Error:</strong> {ex.Message}<br/><br/>";
                errorMsg += "<small>Please make sure:<br/>";
                errorMsg += "1. The database connection string is correct in Web.config<br/>";
                errorMsg += "2. You have permission to create tables in the database<br/>";
                errorMsg += "3. The database exists<br/>";
                errorMsg += "4. The AspNetUsers table exists (Identity tables)</small>";
                
                ShowResult(errorMsg, "alert alert-danger result-box");
                System.Diagnostics.Trace.TraceError($"Database setup error: {ex}");
            }
        }

        private void ShowResult(string message, string cssClass)
        {
            lblResult.Text = message;
            pnlResult.CssClass = cssClass;
            pnlResult.Visible = true;
        }
    }
}
