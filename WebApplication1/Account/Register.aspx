<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="WebApplication1.Account.Register" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    
    <style>
        /* 1. The Full Page Background */
        .register-page {
            /* A seamless paw print pattern background */
            background-color: #ffffff;
            background-image: url("https://www.transparenttextures.com/patterns/dog-paw.png");
            /* If the internet is slow, it falls back to a nice light gray */
            background-color: #f0f2f5; 
        }

        /* 2. The Card Styling */
        .register-card {
            border: none;
            border-radius: 15px;
            /* A slight transparency to see the pattern behind vaguely, or solid white */
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(5px); /* Modern glass effect */
        }

        /* 3. The Welcome Header Area */
        .welcome-header {
            background: #212529; /* Dark background for header */
            color: white;
            border-radius: 15px 15px 0 0; /* Rounded top corners only */
            padding: 20px;
            margin: -1.5rem -1.5rem 1.5rem -1.5rem; /* Pull it to the edges of the card padding */
        }
    </style>

    <main class="d-flex justify-content-center align-items-center min-vh-100 register-page" aria-labelledby="title">
        
        <div class="card shadow-lg p-4 register-card" style="max-width: 500px; width: 100%;">
            
            <div class="welcome-header text-center">
                <h2 class="fw-bold mb-1"><i class="fas fa-paw text-warning me-2"></i>Join the Pack</h2>
                <p class="mb-0 small text-white-50">Create your account to start shopping</p>
            </div>

            <div class="px-2">
                <asp:Literal runat="server" ID="ErrorMessage" />
                <asp:ValidationSummary runat="server" CssClass="alert alert-danger mb-3" DisplayMode="BulletList" />

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="Username" CssClass="form-label fw-bold small text-muted">USERNAME</asp:Label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fas fa-user"></i></span>
                        <asp:TextBox runat="server" ID="Username" CssClass="form-control" placeholder="Choose a username" />
                    </div>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="Username"
                        CssClass="text-danger small" ErrorMessage="Username is required." Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="Username"
                        ValidationExpression="^[a-zA-Z0-9_]{3,20}$"
                        CssClass="text-danger small" ErrorMessage="3-20 chars, letters/numbers only."
                        Display="Dynamic" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="Email" CssClass="form-label fw-bold small text-muted">EMAIL ADDRESS</asp:Label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fas fa-envelope"></i></span>
                        <asp:TextBox runat="server" ID="Email" CssClass="form-control" TextMode="Email" placeholder="name@example.com" />
                    </div>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="Email"
                        CssClass="text-danger small" ErrorMessage="Email is required." Display="Dynamic" />
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <asp:Label runat="server" AssociatedControlID="Password" CssClass="form-label fw-bold small text-muted">PASSWORD</asp:Label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-lock"></i></span>
                            <asp:TextBox runat="server" ID="Password" TextMode="Password" CssClass="form-control" placeholder="******" />
                        </div>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="Password"
                            CssClass="text-danger small" ErrorMessage="Required." Display="Dynamic" />
                    </div>

                    <div class="col-md-6 mb-3">
                        <asp:Label runat="server" AssociatedControlID="ConfirmPassword" CssClass="form-label fw-bold small text-muted">CONFIRM</asp:Label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fas fa-check"></i></span>
                            <asp:TextBox runat="server" ID="ConfirmPassword" TextMode="Password" CssClass="form-control" placeholder="******" />
                        </div>
                        <asp:CompareValidator runat="server" ControlToCompare="Password" ControlToValidate="ConfirmPassword"
                            CssClass="text-danger small" Display="Dynamic" ErrorMessage="No match." />
                    </div>
                </div>

                <div class="mb-4">
                    <asp:Label runat="server" AssociatedControlID="ddlRole" CssClass="form-label fw-bold small text-muted">I WANT TO REGISTER AS</asp:Label>
                    <asp:DropDownList runat="server" ID="ddlRole" CssClass="form-select">
                        <asp:ListItem Text="Customer (I want to buy)" Value="Customer" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="Seller (I want to sell)" Value="Seller"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="d-grid mb-3">
                    <asp:Button runat="server" OnClick="CreateUser_Click" Text="Create Account" CssClass="btn btn-dark btn-lg shadow-sm" />
                </div>

                <div class="text-center">
                    <p class="small text-muted">Already have an account? <asp:HyperLink runat="server" NavigateUrl="Login.aspx" CssClass="text-decoration-none fw-bold">Log In</asp:HyperLink></p>
                </div>
            </div>
        </div>
    </main>
</asp:Content>