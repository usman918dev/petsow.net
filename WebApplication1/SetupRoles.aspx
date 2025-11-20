<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetupRoles.aspx.cs" Inherits="WebApplication1.SetupRoles" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Setup Roles</title>
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
                    <h2>Setup User Roles</h2>
                </div>
                <div class="card-body">
                    <p class="lead">Click the button below to create the required user roles for the application.</p>
                    
                    <div class="alert alert-info">
                        <strong>Roles to be created:</strong>
                        <ul>
                            <li><strong>Customer</strong> - Users who can browse and purchase products</li>
                            <li><strong>Seller</strong> - Users who can list and manage products for sale</li>
                            <li><strong>Admin</strong> - Users with administrative privileges</li>
                        </ul>
                    </div>

                    <asp:Button ID="btnSetupRoles" runat="server" Text="Setup Roles" 
                        CssClass="btn btn-success btn-lg" OnClick="btnSetupRoles_Click" />

                    <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="result-box">
                        <asp:Label ID="lblResult" runat="server"></asp:Label>
                    </asp:Panel>
                </div>
            </div>

            <div class="card mt-4">
                <div class="card-header">
                    <h4>Current Roles in System</h4>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvRoles" runat="server" CssClass="table table-striped" 
                        AutoGenerateColumns="true" EmptyDataText="No roles found in the system.">
                        <HeaderStyle CssClass="thead-dark" />
                    </asp:GridView>
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh Role List" 
                        CssClass="btn btn-secondary mt-2" OnClick="btnRefresh_Click" />
                </div>
            </div>

            <div class="mt-3">
                <asp:HyperLink ID="lnkGoBack" runat="server" NavigateUrl="~/Default.aspx" CssClass="btn btn-primary">
                    Go to Home Page
                </asp:HyperLink>
            </div>
        </div>
    </form>
</body>
</html>
