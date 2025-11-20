<%@ Page Title="My Orders" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CustomerDashboard.aspx.cs" Inherits="WebApplication1.CustomerDashboard" %>
<%@ Register Src="~/Controls/PaginationControl.ascx" TagPrefix="uc" TagName="Pagination" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Custom CSS for mobile cards -->
    <style>
        @media (max-width: 767.98px) {
            .mobile-order-card {
                border-left: 4px solid #007bff;
                transition: transform 0.2s ease-in-out;
            }
            
            .mobile-order-card:hover {
                transform: translateY(-2px);
            }
            
            .status-badge {
                font-size: 0.8rem;
                padding: 0.25rem 0.5rem;
            }
            
            .card-value {
                font-weight: 500;
                color: #212529;
            }
            
            .card-label {
                font-size: 0.75rem;
                font-weight: 600;
                color: #6c757d;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
        }
    </style>
    
    <main class="container my-5">
      <div class="row mb-4">
        <div class="col-md-12">
          <h1 class="display-4">My Orders</h1>
          <p class="lead">View your order history and track your purchases</p>
        </div>
      </div>

      <asp:Label ID="lblMessage" runat="server" CssClass="alert" Visible="false"></asp:Label>

      <asp:Panel ID="pnlOrders" runat="server" Visible="true">
        <!-- Desktop Table View -->
        <div class="d-none d-md-block">
            <div class="table-responsive">
                <asp:GridView ID="gvOrders" runat="server"
                    CssClass="table table-bordered table-striped table-hover mb-0"
                    AutoGenerateColumns="False" DataKeyNames="OrderId"
                    OnRowCommand="gvOrders_RowCommand"
                    EmptyDataText="You haven't placed any orders yet.">

                    <Columns>
                        <asp:BoundField DataField="OrderId" HeaderText="Order #" />
                        <asp:BoundField DataField="OrderDate" HeaderText="Order Date" DataFormatString="{0:MMM dd, yyyy}" />
                        <asp:BoundField DataField="TotalAmount" HeaderText="Total" DataFormatString="${0:0.00}" />
                        <asp:BoundField DataField="Status" HeaderText="Status" />
                        <asp:BoundField DataField="PaymentMethod" HeaderText="Payment" />

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnViewDetails" runat="server"
                                    CssClass="btn btn-sm btn-primary px-2"
                                    CommandName="ViewDetails"
                                    CommandArgument='<%# Eval("OrderId") %>'>
                                    <i class="fas fa-eye"></i> View
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>

                    <HeaderStyle CssClass="table-dark" />
                </asp:GridView>
            </div>
        </div>

        <!-- Mobile Card View -->
        <div class="d-block d-md-none">
            <asp:Repeater ID="rptOrdersMobile" runat="server">
                <ItemTemplate>
                    <div class="card mb-3 shadow-sm mobile-order-card">
                        <div class="card-body p-3">
                            <div class="row">
                                <div class="col-6">
                                    <div class="mb-2">
                                        <div class="card-label">Order #</div>
                                        <div class="card-value fw-bold">#<%# Eval("OrderId") %></div>
                                    </div>
                                    <div class="mb-2">
                                        <div class="card-label">Date</div>
                                        <div class="card-value"><%# Convert.ToDateTime(Eval("OrderDate")).ToString("MMM dd, yyyy") %></div>
                                    </div>
                                </div>
                                <div class="col-6 text-end">
                                    <div class="mb-2">
                                        <div class="card-label">Total</div>
                                        <div class="card-value fw-bold text-success fs-5">${<%# Convert.ToDecimal(Eval("TotalAmount")).ToString("0.00") %></div>
                                    </div>
                                    <div class="mb-2">
                                        <div class="card-label">Status</div>
                                        <div style="color: rgb(33, 37, 41);">
                                            <span class="badge <%# GetStatusBadgeClass(Eval("Status").ToString()) %>">
                                                <%# Eval("Status") %>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <hr class="my-2">
                            <div class="row align-items-center">
                                <div class="col-6">
                                    <div class="card-label">Payment</div>
                                    <div class="card-value small"><%# Eval("PaymentMethod") %></div>
                                </div>
                                <div class="col-6 text-end">
                                    <asp:LinkButton ID="btnViewDetailsMobile" runat="server"
                                        CssClass="btn btn-outline-primary btn-sm px-3"
                                        CommandName="ViewDetails"
                                        CommandArgument='<%# Eval("OrderId") %>'
                                        OnCommand="MobileViewDetails_Command">
                                        <i class="fas fa-eye me-1"></i>View
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Panel ID="pnlNoOrdersMobile" runat="server" Visible='<%# ((Repeater)Container.NamingContainer).Items.Count == 0 %>'>
                        <div class="card text-center py-5">
                            <div class="card-body">
                                <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted mb-3">No Orders Yet</h5>
                                <p class="text-muted mb-4">You haven't placed any orders yet. Start shopping for your pets now!</p>
                                <asp:Button ID="btnStartShopping" runat="server" 
                                    Text="Start Shopping" 
                                    CssClass="btn btn-primary px-4"
                                    OnClick="btnContinueShopping_Click" />
                            </div>
                        </div>
                    </asp:Panel>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- Pagination Control -->
        <uc:Pagination ID="ordersPagination" runat="server" 
            OnPageChanged="ordersPagination_PageChanged" 
            OnPageSizeChanged="ordersPagination_PageSizeChanged" />
    </asp:Panel>


      <!-- Order Details Modal Panel -->
      <asp:Panel ID="pnlOrderDetails" runat="server" Visible="false" CssClass="mt-3">
        <div class="card shadow-sm border rounded">
          <div class="card-header bg-primary text-white py-2 px-3 d-flex justify-content-between align-items-center">
            <span class="fw-bold">Order Details - #<asp:Label ID="lblOrderId" runat="server"></asp:Label></span>
            <asp:Button ID="btnCloseDetails" runat="server" Text="Close" CssClass="btn btn-light btn-sm" OnClick="btnCloseDetails_Click" />
          </div>
          <div class="card-body py-3 px-3">
            <div class="row mb-3">
              <div class="col-12 col-md-6 mb-2 mb-md-0 border-end pe-md-3">
                <div class="mb-2"><strong>Name:</strong> <asp:Label ID="lblCustomerName" runat="server"></asp:Label></div>
                <div class="mb-2"><strong>Phone:</strong> <asp:Label ID="lblPhone" runat="server"></asp:Label></div>
                <div class="mb-2"><strong>Email:</strong> <asp:Label ID="lblEmail" runat="server"></asp:Label></div>
                <div class="mb-2"><strong>Address:</strong> <asp:Label ID="lblAddress" runat="server"></asp:Label></div>
              </div>
              <div class="col-12 col-md-6 ps-md-3">
                <div class="mb-2"><strong>Order Date:</strong> <asp:Label ID="lblOrderDate" runat="server"></asp:Label></div>
                <div class="mb-2 d-flex align-items-center">
                  <strong>Status:</strong>
                  <asp:Label ID="lblStatus" runat="server" class="ms-2 px-2 py-1 border rounded"
                    style="min-width: 60px; font-size: 16px; font-weight: 400; text-align:center;color: rgb(33, 37, 41); display:inline-block;"></asp:Label>
                </div>
                <div class="mb-2"><strong>Payment:</strong> <asp:Label ID="lblPaymentMethod" runat="server"></asp:Label></div>
                <div class="mb-2"><strong>Total:</strong> $<asp:Label ID="lblTotalAmount" runat="server"></asp:Label></div>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table table-sm table-bordered mb-0 text-nowrap">
                <thead class="table-light">
                  <tr>
                    <th>Product</th>
                    <th>Price</th>
                    <th>Qty</th>
                    <th>Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  <asp:Repeater ID="rptOrderItems" runat="server">
                    <ItemTemplate>
                      <tr>
                        <td><%# Eval("ProductName") %></td>
                        <td>$<%# Eval("Price", "{0:0.00}") %></td>
                        <td><%# Eval("Quantity") %></td>
                        <td>$<%# Convert.ToDecimal(Eval("Price")) * Convert.ToInt32(Eval("Quantity")) %></td>
                      </tr>
                    </ItemTemplate>
                  </asp:Repeater>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </asp:Panel>



      <div class="mt-4">
        <asp:Button ID="btnContinueShopping" runat="server" Text="Continue Shopping"
          CssClass="btn btn-primary" OnClick="btnContinueShopping_Click" />
      </div>
    </main>
  </asp:Content>
