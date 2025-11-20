<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetupDatabase.aspx.cs" Inherits="WebApplication1.SetupDatabase" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Database Setup</title>
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <style>
        .container { margin-top: 50px; }
        .result-box { 
            margin-top: 20px; 
            padding: 15px; 
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h2>Database Setup Utility</h2>
                </div>
                <div class="card-body">
                    <p class="lead">Click the button below to create the required database tables for the e-commerce functionality.</p>
                    
                    <div class="alert alert-info">
                        <strong>Tables to be created:</strong>
                        <ul>
                            <li><strong>Orders</strong> - Stores customer orders</li>
                            <li><strong>OrderItems</strong> - Stores individual items in each order</li>
                        </ul>
                    </div>

                    <asp:Button ID="btnSetupDatabase" runat="server" Text="Setup Database Tables" 
                        CssClass="btn btn-success btn-lg" OnClick="btnSetupDatabase_Click" />

                    <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="result-box">
                        <asp:Label ID="lblResult" runat="server"></asp:Label>
                    </asp:Panel>
                </div>
            </div>

            <div class="card mt-4">
                <div class="card-header">
                    <h4>SQL Script Preview</h4>
                </div>
                <div class="card-body">
                    <pre style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto;">
CREATE TABLE [Orders](
    [OrderId] [int] IDENTITY(1,1) PRIMARY KEY,
    [CustomerName] [nvarchar](100) NOT NULL,
    [Address] [nvarchar](500) NOT NULL,
    [Phone] [nvarchar](15) NOT NULL,
    [Email] [nvarchar](100) NULL,
    [PaymentMethod] [nvarchar](50) NOT NULL,
    [TotalAmount] [decimal](18, 2) NOT NULL,
    [OrderDate] [datetime] NOT NULL,
    [Status] [nvarchar](50) NOT NULL
)

CREATE TABLE [OrderItems](
    [OrderItemId] [int] IDENTITY(1,1) PRIMARY KEY,
    [OrderId] [int] NOT NULL,
    [ProductId] [int] NOT NULL,
    [ProductName] [nvarchar](200) NOT NULL,
    [Quantity] [int] NOT NULL,
    [Price] [decimal](18, 2) NOT NULL,
    FOREIGN KEY([OrderId]) REFERENCES [Orders]([OrderId]) ON DELETE CASCADE
)
                    </pre>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
