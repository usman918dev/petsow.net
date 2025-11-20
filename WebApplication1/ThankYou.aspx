<%@ Page Title="Order Confirmation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ThankYou.aspx.cs" Inherits="WebApplication1.ThankYou" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        .thank-you-page {
            background-color: #f8f9fa;
            min-height: 90vh;
            padding: 4rem 0;
        }

        .success-card {
            border: none;
            border-radius: 16px;
            background: #fff;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        /* The Green Success Banner at the top */
        .success-header {
            background: linear-gradient(135deg, #d1e7dd 0%, #badbcc 100%);
            color: #0f5132;
            padding: 3rem 2rem;
            position: relative;
            text-align: center;
        }

        .check-icon-circle {
            width: 90px;
            height: 90px;
            background: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }

        /* The Grid Box for Order ID and Date */
        .order-info-box {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 1.5rem;
            border: 1px dashed #dee2e6;
        }

        /* Receipt Table Styling */
        .receipt-table th {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #6c757d;
            border-top: none;
            font-weight: 700;
            padding-bottom: 1rem;
        }
        
        .receipt-table td {
            padding: 1rem 0.5rem;
            vertical-align: middle;
        }
    </style>

    <div class="thank-you-page">
        <main class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8 col-md-10">
                    
                    <div class="card success-card">
                        
                        <!-- 1. Success Header -->
                        <div class="success-header">
                            <div class="check-icon-circle">
                                <i class="fas fa-check fa-3x text-success"></i>
                            </div>
                            <h2 class="fw-bold mb-2">Thank You!</h2>
                            <p class="mb-0 opacity-75 lead">Your order has been successfully placed.</p>
                        </div>

                        <div class="card-body p-4 p-md-5">
                            
                            <asp:Panel ID="pnlOrderDetails" runat="server">
                                
                                <!-- 2. Order Info Summary Box -->
                                <div class="order-info-box mb-5">
                                    <div class="row g-3 text-center">
                                        <div class="col-sm-4 border-end-sm">
                                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.7rem;">ORDER ID</small>
                                            <span class="fw-bold text-dark fs-5">#<asp:Label ID="lblOrderId" runat="server"></asp:Label></span>
                                        </div>
                                        <div class="col-sm-4 border-end-sm">
                                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.7rem;">DATE</small>
                                            <span class="fw-bold text-dark"><asp:Label ID="lblOrderDate" runat="server"></asp:Label></span>
                                        </div>
                                        <div class="col-sm-4">
                                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.7rem;">METHOD</small>
                                            <span class="badge bg-dark text-white">COD</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- 3. Customer & Address Columns -->
                                <div class="row mb-5">
                                    <div class="col-md-6 mb-4 mb-md-0">
                                        <h6 class="fw-bold text-uppercase text-muted small mb-3 ps-1 border-start border-3 border-primary">Customer Details</h6>
                                        <div class="ps-2">
                                            <p class="mb-1 fw-bold text-dark"><asp:Label ID="lblCustomerName" runat="server"></asp:Label></p>
                                            <p class="mb-0 text-secondary"><i class="fas fa-phone-alt me-2 small opacity-50"></i><asp:Label ID="lblPhone" runat="server"></asp:Label></p>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <h6 class="fw-bold text-uppercase text-muted small mb-3 ps-1 border-start border-3 border-danger">Delivery Address</h6>
                                        <div class="ps-2">
                                            <p class="mb-0 text-secondary" style="line-height: 1.6;">
                                                <asp:Label ID="lblAddress" runat="server"></asp:Label>
                                            </p>
                                        </div>
                                    </div>
                                </div>

                                <!-- 4. Items Table -->
                                <h6 class="fw-bold text-uppercase text-muted small mb-3">Order Summary</h6>
                                <div class="table-responsive mb-4">
                                    <table class="table receipt-table mb-0">
                                        <thead class="border-bottom">
                                            <tr>
                                                <th scope="col" class="ps-2" style="width: 50%;">ITEM</th>
                                                <th scope="col" class="text-center">QTY</th>
                                                <th scope="col" class="text-end">PRICE</th>
                                                <th scope="col" class="text-end pe-2">TOTAL</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <asp:Repeater ID="rptOrderItems" runat="server">
                                                <ItemTemplate>
                                                    <tr class="border-bottom">
                                                        <td class="ps-2">
                                                            <span class="fw-bold text-dark"><%# Eval("ProductName") %></span>
                                                        </td>
                                                        <td class="text-center text-muted"><%# Eval("Quantity") %></td>
                                                        <td class="text-end text-muted">$<%# Eval("Price", "{0:0.00}") %></td>
                                                        <td class="text-end pe-2 fw-bold text-dark">$<%# Convert.ToDecimal(Eval("Price")) * Convert.ToInt32(Eval("Quantity")) %></td>
                                                    </tr>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <td colspan="3" class="text-end pt-4 pb-0">Grand Total</td>
                                                <td class="text-end pe-2 pt-4 pb-0">
                                                    <span class="h4 fw-bold text-primary">$<asp:Label ID="lblTotalAmount" runat="server"></asp:Label></span>
                                                </td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>

                                <!-- 5. Info Alert -->
                                <div class="alert alert-warning border-0 d-flex align-items-center bg-light text-dark" role="alert">
                                    <i class="fas fa-wallet text-warning fs-4 me-3"></i>
                                    <div>
                                        <div class="fw-bold">Payment Pending</div>
                                        <small class="text-muted">Please have the exact amount ready for the courier.</small>
                                    </div>
                                </div>

                            </asp:Panel>

                            <!-- Error Handling -->
                            <asp:Panel ID="pnlError" runat="server" Visible="false">
                                <div class="alert alert-danger text-center shadow-sm border-0">
                                    <i class="fas fa-exclamation-circle me-2"></i>
                                    <asp:Label ID="lblError" runat="server"></asp:Label>
                                </div>
                            </asp:Panel>

                            <!-- Action Button -->
                            <div class="text-center mt-5">
                                <asp:Button ID="btnContinueShopping" runat="server" Text="Continue Shopping" 
                                    CssClass="btn btn-dark btn-lg rounded-pill px-5 shadow-sm" OnClick="btnContinueShopping_Click" />
                                <p class="mt-3 mb-0 small text-muted">A confirmation email has been sent to you.</p>
                            </div>

                        </div>
                    </div>

                </div>
            </div>
        </main>
    </div>
</asp:Content>