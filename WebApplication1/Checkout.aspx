<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" 
    CodeBehind="Checkout.aspx.cs" Inherits="WebApplication1.Checkout" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .checkout-page {
            background-color: #f8f9fa;
            min-height: 90vh;
            padding-top: 2rem;
            padding-bottom: 4rem;
        }

        .checkout-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.04);
            background: white;
            overflow: hidden;
        }

        .checkout-header {
            padding: 1.5rem;
            border-bottom: 1px solid #f0f0f0;
            background: #fff;
        }

        .checkout-header h5 {
            margin: 0;
            font-weight: 700;
            color: #2c3e50;
            display: flex;
            align-items: center;
        }

        /* Input Group Styling */
        .input-group-text {
            background-color: #f8f9fa;
            border-right: none;
            color: #6c757d;
        }
        
        .form-control {
            border-left: none;
        }
        
        .form-control:focus {
            box-shadow: none;
            border-color: #ced4da;
        }

        /* Focus state for input group wrapper */
        .input-group:focus-within .input-group-text,
        .input-group:focus-within .form-control {
            border-color: #86b7fe;
        }

        /* Order Item Row */
        .order-item {
            padding: 12px 0;
            border-bottom: 1px dashed #eee;
        }

        .order-item:last-child {
            border-bottom: none;
        }

        /* Payment Box styling */
        .payment-option {
            border: 2px solid #0d6efd; /* Selected blue border */
            background-color: #f8fbff;
            border-radius: 8px;
            padding: 15px;
        }
    </style>

    <div class="checkout-page">
        <main class="container">

            <div class="mb-4">
                <h2 class="fw-bold text-dark"><i class="fas fa-lock text-primary me-2"></i>Secure Checkout</h2>
                <p class="text-muted">Complete your order securely</p>
            </div>

            <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block mb-4 shadow-sm" Visible="false">
                <i class="fas fa-exclamation-triangle me-2"></i> <asp:Literal ID="litErrorMsg" runat="server"></asp:Literal>
            </asp:Label>

            <div class="row g-4">

                <!-- LEFT SIDE - CUSTOMER INFO -->
                <div class="col-lg-7">
                    <div class="card checkout-card h-100">
                        <div class="checkout-header">
                            <h5><i class="fas fa-user-circle text-primary me-2"></i> Shipping Details</h5>
                        </div>

                        <div class="card-body p-4">
                            
                            <div class="row g-3">
                                <!-- Name -->
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">FULL NAME <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="John Doe"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" 
                                        CssClass="text-danger small" ErrorMessage="Required" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>

                                <!-- Phone -->
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">PHONE NUMBER <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-phone"></i></span>
                                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="03xx-xxxxxxx"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" 
                                        CssClass="text-danger small" ErrorMessage="Required" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>

                                <!-- Address -->
                                <div class="col-12">
                                    <label class="form-label fw-bold small text-muted">DELIVERY ADDRESS <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-map-marker-alt"></i></span>
                                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" 
                                            placeholder="Street, House No, City, etc." Rows="2"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress" 
                                        CssClass="text-danger small" ErrorMessage="Address is required" Display="Dynamic"></asp:RequiredFieldValidator>
                                </div>

                                <!-- Email -->
                                <div class="col-12">
                                    <label class="form-label fw-bold small text-muted">EMAIL (OPTIONAL)</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="For order updates"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <hr class="my-4 opacity-25">

                            <!-- Payment Method -->
                            <h5 class="mb-3 fw-bold text-dark small text-uppercase">Payment Method</h5>
                            
                            <div class="payment-option d-flex align-items-center">
                                <div class="form-check mb-0">
                                    <input type="radio" class="form-check-input" checked id="radioCOD" name="paymentMethod" />
                                    <label class="form-check-label fw-bold text-dark" for="radioCOD">
                                        Cash on Delivery (COD)
                                    </label>
                                </div>
                                <i class="fas fa-money-bill-wave ms-auto text-primary fa-lg"></i>
                            </div>
                            <small class="text-muted mt-2 d-block ms-1">You will pay securely when the courier arrives.</small>

                        </div>
                    </div>
                </div>

                <!-- RIGHT SIDE - ORDER SUMMARY -->
                <div class="col-lg-5">
                    <div class="card checkout-card bg-white h-100 border border-light">
                        <div class="checkout-header bg-light border-bottom-0">
                            <h5><i class="fas fa-receipt text-muted me-2"></i> Order Summary</h5>
                        </div>

                        <div class="card-body p-4">
                            <div class="bg-light rounded p-3 mb-3">
                                <asp:Repeater ID="rptOrderSummary" runat="server">
                                    <ItemTemplate>
                                        <div class="order-item d-flex justify-content-between align-items-center">
                                            <div>
                                                <div class="fw-bold text-dark"><%# Eval("ProductName") %></div>
                                                <div class="small text-muted">Qty: <%# Eval("Quantity") %> × $<%# Eval("Price", "{0:0.00}") %></div>
                                            </div>
                                            <div class="fw-bold text-dark">
                                                $<%# Eval("Subtotal","{0:0.00}") %>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- Totals -->
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Subtotal</span>
                                <span class="fw-bold">$<asp:Label ID="lblSubtotal" runat="server"></asp:Label></span>
                            </div>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Shipping</span>
                                <span class="text-success fw-bold">Free</span>
                            </div>

                            <hr />

                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <span class="h5 fw-bold mb-0">Total Amount</span>
                                <span class="h4 fw-bold text-primary mb-0">
                                    $<asp:Label ID="lblTotal" runat="server"></asp:Label>
                                </span>
                            </div>

                            <asp:Button ID="btnConfirmOrder" runat="server"
                                CssClass="btn btn-primary btn-lg w-100 mb-3 shadow-sm"
                                Text="Confirm Order"
                                OnClick="btnConfirmOrder_Click" />

                            <asp:Button ID="btnCancel" runat="server"
                                CssClass="btn btn-outline-secondary w-100 border-0"
                                Text="Back to Cart"
                                CausesValidation="false"
                                OnClick="btnCancel_Click" />
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

</asp:Content>