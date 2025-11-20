<%@ Page Title="Log in" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebApplication1.Account.Login" Async="true" %>

<asp:Content runat="server" ID="BodyContent" ContentPlaceHolderID="MainContent">
    
    <style>
        /* 1. The Full Page Background (Same as Register) */
        .login-page {
            background-color: #ffffff;
            background-image: url("https://www.transparenttextures.com/patterns/dog-paw.png");
            background-color: #f0f2f5; 
        }

        /* 2. The Card Styling */
        .login-card {
            border: none;
            border-radius: 15px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(5px);
        }

        /* 3. The Header Area */
        .login-header {
            background: #212529;
            color: white;
            border-radius: 15px 15px 0 0;
            padding: 20px;
            margin: -1.5rem -1.5rem 1.5rem -1.5rem;
        }
    </style>

    <main class="d-flex justify-content-center align-items-center min-vh-100 login-page" aria-labelledby="title">
        
        <div class="card shadow-lg p-4 login-card" style="max-width: 400px; width: 100%;">
            
            <div class="login-header text-center">
                <h2 class="fw-bold mb-1"><i class="fas fa-paw text-warning me-2"></i>Welcome Back</h2>
                <p class="mb-0 small text-white-50">Please login to your account</p>
            </div>

            <asp:PlaceHolder runat="server" ID="ErrorMessage" Visible="false">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    <asp:Literal runat="server" ID="FailureText" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </asp:PlaceHolder>

            <section id="loginForm" class="px-2">
                
                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="Email" CssClass="form-label fw-bold small text-muted">EMAIL ADDRESS</asp:Label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fas fa-envelope"></i></span>
                        <asp:TextBox runat="server" ID="Email" CssClass="form-control" TextMode="Email" placeholder="name@example.com" />
                    </div>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="Email"
                        CssClass="text-danger small" ErrorMessage="The email field is required." Display="Dynamic" />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="Password" CssClass="form-label fw-bold small text-muted">PASSWORD</asp:Label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fas fa-lock"></i></span>
                        <asp:TextBox runat="server" ID="Password" TextMode="Password" CssClass="form-control" placeholder="******" />
                    </div>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="Password"
                        CssClass="text-danger small" ErrorMessage="The password field is required." Display="Dynamic" />
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <asp:CheckBox runat="server" ID="RememberMe" CssClass="form-check-input" />
                        <asp:Label runat="server" AssociatedControlID="RememberMe" CssClass="form-check-label small text-muted pt-1">Keep me logged in</asp:Label>
                    </div>
                </div>

                <div class="d-grid mb-4">
                    <asp:Button runat="server" OnClick="LogIn" Text="Log in" CssClass="btn btn-dark btn-lg shadow-sm" />
                </div>

                <div class="text-center border-top pt-3">
                    <p class="small text-muted">Don't have an account?</p>
                    <asp:HyperLink runat="server" ID="RegisterHyperLink" NavigateUrl="Register.aspx" CssClass="btn btn-outline-secondary btn-sm w-100">Create New Account</asp:HyperLink>
                </div>

            </section>
        </div>
    </main>
</asp:Content>