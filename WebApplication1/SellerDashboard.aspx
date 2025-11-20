<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SellerDashboard.aspx.cs" MasterPageFile="~/Site.Master" Inherits="WebApplication1.SellerDashboard" %>
<%@ Register Src="~/Controls/PaginationControl.ascx" TagPrefix="uc" TagName="Pagination" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* --- MODERN DASHBOARD THEME --- */
        .dashboard-page {
            background-color: #f8f9fa;
            min-height: 90vh;
            padding-top: 2rem;
            padding-bottom: 4rem;
        }

        .dashboard-card {
            border: none;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }

        .dashboard-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #f0f0f0;
            background: #fff;
        }

        .dashboard-header h5 {
            margin: 0;
            font-weight: 700;
            color: #2c3e50;
        }

        /* Nav Tabs Styling (Pills) */
        .nav-pills .nav-link {
            border-radius: 50px;
            padding: 0.6rem 1.5rem;
            font-weight: 600;
            color: #6c757d;
            margin-right: 0.5rem;
            transition: all 0.2s;
            border: 1px solid transparent;
            cursor: pointer;
        }

        .nav-pills .nav-link.active {
            background-color: #212529; /* Dark theme active */
            color: #fff;
            box-shadow: 0 4px 6px rgba(33, 37, 41, 0.3);
        }

        .nav-pills .nav-link:hover:not(.active) {
            background-color: #fff;
            border-color: #dee2e6;
            color: #000;
        }

        /* Stat Cards */
        .stat-card {
            border: none;
            border-radius: 12px;
            padding: 1.5rem;
            color: white;
            height: 100%;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-5px); }

        .bg-gradient-primary { background: linear-gradient(45deg, #4e73df, #224abe); }
        .bg-gradient-success { background: linear-gradient(45deg, #1cc88a, #13855c); }
        .bg-gradient-warning { background: linear-gradient(45deg, #f6c23e, #dda20a); }
        .bg-gradient-danger { background: linear-gradient(45deg, #e74a3b, #be2617); }
        .bg-gradient-info { background: linear-gradient(45deg, #36b9cc, #258391); }
        .bg-gradient-dark { background: linear-gradient(45deg, #5a5c69, #373840); }
        .bg-gradient-secondary { background: linear-gradient(45deg, #858796, #60616f); }
        
        .stat-icon-bg {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 3rem;
            opacity: 0.2;
        }

        /* Input Groups & Forms */
        .input-group-text {
            background-color: #f8f9fa;
            border-right: none;
            color: #6c757d;
        }
        .form-control, .form-select {
            border-left: none;
            box-shadow: none !important;
        }
        .input-group:focus-within .input-group-text,
        .input-group:focus-within .form-control,
        .input-group:focus-within .form-select {
            border-color: #86b7fe;
        }
        
        /* GridView Images */
        .product-thumb {
            width: 50px; 
            height: 50px; 
            object-fit: cover; 
            border-radius: 6px;
            border: 1px solid #dee2e6;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .product-thumb:hover { transform: scale(1.1); }

        /* --- MOBILE TABLE CARDS (Responsive GridView) --- */
        @media screen and (max-width: 992px) {
            .mobile-card-table thead { display: none !important; }
            
            .mobile-card-table, .mobile-card-table tbody, .mobile-card-table tr, .mobile-card-table td {
                display: block;
                width: 100%;
            }

            .mobile-card-table tr {
                margin-bottom: 1rem;
                border: 1px solid #eee;
                border-radius: 10px;
                background: #fff;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
                padding: 15px;
            }

            .mobile-card-table td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                text-align: right;
                padding: 10px 0;
                border-bottom: 1px dashed #f0f0f0;
                position: relative;
            }

            .mobile-card-table td:last-child { border-bottom: none; justify-content: center; gap: 5px; padding-top: 15px; }

            /* Labels via CSS */
            .mobile-card-table td:before {
                content: attr(data-label); 
                font-weight: 700;
                color: #6c757d;
                font-size: 0.8rem;
                text-transform: uppercase;
                margin-right: auto; 
            }

            /* Specific Labels */
            #<%= gvProducts.ClientID %> td:nth-of-type(1):before { content: "ID"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(2):before { content: "Product"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(3):before { content: "Price"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(4):before { content: "Stock"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(5):before { content: "Stock Status"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(6):before { content: "Status"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(7):before { content: "Image"; }
            #<%= gvProducts.ClientID %> td:nth-of-type(8):before { content: ""; display: none; }

            #<%= gvOrders.ClientID %> td:nth-of-type(1):before { content: "Order #"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(2):before { content: "Product"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(3):before { content: "Qty"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(4):before { content: "Price"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(5):before { content: "Total"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(6):before { content: "Customer"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(7):before { content: "Date"; }
            #<%= gvOrders.ClientID %> td:nth-of-type(8):before { content: "Status"; }
            
            .hide-desk { display: none; }
        }
    </style>

    <div class="dashboard-page">
        <div class="container">
            
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold text-dark mb-0">Seller Dashboard</h2>
                    <p class="text-muted mb-0">Manage your store, products, and orders.</p>
                </div>
            </div>

            <asp:HiddenField ID="hfActiveTab" runat="server" Value="add-product" />

            <!-- Modern Pills Navigation -->
            <ul class="nav nav-pills mb-4" id="sellerTabs" role="tablist">
                <li class="nav-item">
                    <button class="nav-link" id="add-product-tab" data-bs-toggle="pill" data-bs-target="#add-product" type="button" onclick="setActiveTab('add-product')">
                        <i class="fas fa-plus me-1"></i> Add Product
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" id="products-tab" data-bs-toggle="pill" data-bs-target="#products" type="button" onclick="setActiveTab('products')">
                        <i class="fas fa-box-open me-1"></i> My Products
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" id="orders-tab" data-bs-toggle="pill" data-bs-target="#orders" type="button" onclick="setActiveTab('orders')">
                        <i class="fas fa-clipboard-list me-1"></i> Orders
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" id="stats-tab" data-bs-toggle="pill" data-bs-target="#stats" type="button" onclick="setActiveTab('stats')">
                        <i class="fas fa-chart-pie me-1"></i> Statistics
                    </button>
                </li>
            </ul>

            <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-info d-block shadow-sm border-0 mb-4" Visible="false"></asp:Label>

            <div class="tab-content">

                <!-- TAB 1: ADD PRODUCT -->
                <div class="tab-pane fade show active" id="add-product">
                    <div class="dashboard-card">
                        <div class="dashboard-header">
                            <h5><i class="fas fa-plus-circle text-primary me-2"></i><asp:Literal ID="litFormTitle" runat="server" Text="Add New Product"></asp:Literal></h5>
                        </div>
                        <div class="card-body p-4">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">PRODUCT NAME <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-tag"></i></span>
                                        <asp:TextBox ID="txtAddName" runat="server" CssClass="form-control" placeholder="e.g. Premium Dog Food"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvAddName" runat="server" ControlToValidate="txtAddName" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold small text-muted">PRICE ($) <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-dollar-sign"></i></span>
                                        <asp:TextBox ID="txtAddPrice" runat="server" CssClass="form-control" placeholder="0.00" TextMode="Number" step="0.01"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvAddPrice" runat="server" ControlToValidate="txtAddPrice" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-bold small text-muted">STOCK <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-layer-group"></i></span>
                                        <asp:TextBox ID="txtAddStock" runat="server" CssClass="form-control" placeholder="0" TextMode="Number" min="0"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvAddStock" runat="server" ControlToValidate="txtAddStock" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label fw-bold small text-muted">DESCRIPTION</label>
                                    <asp:TextBox ID="txtAddDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control border" placeholder="Enter product details..." MaxLength="1000"></asp:TextBox>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">STOCK STATUS</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-info-circle"></i></span>
                                        <asp:DropDownList ID="ddlAddStockStatus" runat="server" CssClass="form-select">
                                            <asp:ListItem Text="In Stock" Value="In Stock" Selected="True"></asp:ListItem>
                                            <asp:ListItem Text="Out of Stock" Value="Out of Stock"></asp:ListItem>
                                            <asp:ListItem Text="Limited Stock" Value="Limited Stock"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">PRODUCT IMAGE</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-image"></i></span>
                                        <asp:FileUpload ID="fileAddImage" runat="server" CssClass="form-control" />
                                    </div>
                                </div>

                                <div class="col-12 text-end mt-4">
                                    <asp:Button ID="btnAddProduct" runat="server" Text="Add Product" CssClass="btn btn-dark px-4 shadow-sm" OnClick="btnAddProduct_Click" />
                                    <asp:Button ID="btnClearForm" runat="server" Text="Clear" CssClass="btn btn-outline-secondary px-4 ms-2" OnClick="btnClearForm_Click" CausesValidation="false" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: MY PRODUCTS -->
                <div class="tab-pane fade" id="products">
                    
                    <!-- Edit Panel (Hidden by default, visible when editing) -->
                    <asp:Panel ID="pnlEditProduct" runat="server" Visible="false" CssClass="dashboard-card border border-primary shadow">
                        <div class="dashboard-header bg-primary text-white">
                            <h5 class="text-white mb-0"><i class="fas fa-edit me-2"></i><asp:Literal ID="litEditFormTitle" runat="server" Text="Edit Product"></asp:Literal></h5>
                        </div>
                        <div class="card-body p-4">
                            <div class="row g-3">
                                <asp:HiddenField ID="hdnProductId" runat="server" />
                                
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">PRODUCT NAME</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control border" placeholder="Name"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold small text-muted">PRICE</label>
                                    <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control border" TextMode="Number" step="0.01"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtPrice" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold small text-muted">STOCK</label>
                                    <asp:TextBox ID="txtStock" runat="server" CssClass="form-control border" TextMode="Number"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvStock" runat="server" ControlToValidate="txtStock" ErrorMessage="Required" CssClass="text-danger small" Display="Dynamic" />
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label fw-bold small text-muted">DESCRIPTION</label>
                                    <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control border"></asp:TextBox>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">STOCK STATUS</label>
                                    <asp:DropDownList ID="ddlStockStatus" runat="server" CssClass="form-select border">
                                        <asp:ListItem Text="In Stock" Value="In Stock"></asp:ListItem>
                                        <asp:ListItem Text="Out of Stock" Value="Out of Stock"></asp:ListItem>
                                        <asp:ListItem Text="Limited Stock" Value="Limited Stock"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted">UPDATE IMAGE</label>
                                    <asp:FileUpload ID="fileImage" runat="server" CssClass="form-control border" />
                                    <asp:Label ID="lblCurrentImage" runat="server" CssClass="form-text text-muted mt-1" Visible="false"></asp:Label>
                                </div>
                                <div class="col-12 text-end mt-3">
                                    <asp:Button ID="btnAdd" runat="server" Text="Save Changes" CssClass="btn btn-success px-4" OnClick="btnAdd_Click" />
                                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline-secondary px-4 ms-2" OnClick="btnCancel_Click" CausesValidation="false" />
                                </div>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- Product List Container (Will be hidden via JS if Edit Panel is visible) -->
                    <div id="productListContainer" class="dashboard-card">
                        <div class="dashboard-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <h5 class="mb-0">Product List</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select form-select-sm w-auto border-0 bg-light" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                                    <asp:ListItem Text="Filter: All" Value="" />
                                    <asp:ListItem Text="Approved" Value="Approved" />
                                    <asp:ListItem Text="Pending" Value="Pending" />
                                    <asp:ListItem Text="Rejected" Value="Rejected" />
                                </asp:DropDownList>
                                <input type="text" id="txtSearchProduct" placeholder="Search..." class="form-control form-control-sm w-auto border-0 bg-light" onkeyup="filterProductTable()" />
                                <asp:Button ID="btnRefreshProducts" runat="server" Text="Refresh" CssClass="btn btn-sm btn-light border" OnClick="btnRefreshProducts_Click" />
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvProducts" runat="server" AutoGenerateColumns="False" DataKeyNames="Id"
                                CssClass="table table-hover align-middle mb-0 mobile-card-table" GridLines="None"
                                OnRowCommand="gvProducts_RowCommand" OnRowDeleting="gvProducts_RowDeleting"
                                OnRowEditing="gvProducts_RowEditing" OnRowCancelingEdit="gvProducts_RowCancelingEdit"
                                OnRowUpdating="gvProducts_RowUpdating">
                                <HeaderStyle CssClass="bg-light text-muted small text-uppercase fw-bold border-bottom" />
                                <Columns>
                                    <asp:BoundField DataField="Id" HeaderText="ID" ReadOnly="true" />
                                    <asp:BoundField DataField="Name" HeaderText="Product Name" ReadOnly="true">
                                        <ItemStyle Font-Bold="true" />
                                    </asp:BoundField>
                                    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="${0:0.00}" ReadOnly="true" />
                                    <asp:TemplateField HeaderText="Stock">
                                        <ItemTemplate><%# Eval("Stock") %></ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:TextBox ID="txtEditStock" runat="server" Text='<%# Bind("Stock") %>' CssClass="form-control form-control-sm" TextMode="Number" Width="70px"></asp:TextBox>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Stock Status">
                                        <ItemTemplate>
                                            <span class='badge rounded-pill bg-light text-dark border'><%# Eval("StockStatus") %></span>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:DropDownList ID="ddlEditStockStatus" runat="server" CssClass="form-select form-select-sm" SelectedValue='<%# Bind("StockStatus") %>'>
                                                <asp:ListItem Text="In Stock" Value="In Stock" />
                                                <asp:ListItem Text="Out of Stock" Value="Out of Stock" />
                                                <asp:ListItem Text="Limited Stock" Value="Limited Stock" />
                                            </asp:DropDownList>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='badge rounded-pill <%# GetStatusBadge(Eval("Status").ToString()) %>'><%# Eval("Status") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Image">
                                        <ItemTemplate>
                                            <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>' class="product-thumb" onclick='showImageModal("<%# ResolveUrl(Eval("ImageUrl").ToString()) %>")' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:Button ID="btnEditProduct" runat="server" CommandName="EditProduct" CommandArgument='<%# Eval("Id") %>' Text="Edit" CssClass="btn btn-sm btn-outline-primary py-0" />
                                            <asp:Button ID="btnEditStock" runat="server" CommandName="Edit" Text="Stock" CssClass="btn btn-sm btn-outline-warning py-0" />
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-outline-danger py-0 border-0" OnClientClick="return confirm('Delete this product?');"><i class="fas fa-trash"></i></asp:LinkButton>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:Button ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="btn btn-sm btn-success py-0" />
                                            <asp:Button ID="btnCancelEdit" runat="server" CommandName="Cancel" Text="Cancel" CssClass="btn btn-sm btn-light border py-0" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            <div class="p-3 border-top">
                                <uc:Pagination ID="productsPagination" runat="server" OnPageChanged="productsPagination_PageChanged" OnPageSizeChanged="productsPagination_PageSizeChanged" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 3: ORDERS -->
                <div class="tab-pane fade" id="orders">
                    <div class="dashboard-card">
                        <div class="dashboard-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                            <h5 class="mb-0">Order History</h5>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:DropDownList ID="ddlOrderStatusFilter" runat="server" CssClass="form-select form-select-sm w-auto border-0 bg-light" AutoPostBack="true" OnSelectedIndexChanged="ddlOrderStatusFilter_SelectedIndexChanged">
                                    <asp:ListItem Text="Filter: All" Value="" />
                                    <asp:ListItem Text="Pending" Value="Pending" />
                                    <asp:ListItem Text="Completed" Value="Completed" />
                                    <asp:ListItem Text="Cancelled" Value="Cancelled" />
                                </asp:DropDownList>
                                <input type="text" id="txtSearchOrder" placeholder="Search orders..." class="form-control form-control-sm w-auto border-0 bg-light" onkeyup="filterOrderTable()" />
                                <asp:Button ID="btnRefreshOrders" runat="server" Text="Refresh" CssClass="btn btn-sm btn-light border" OnClick="btnRefreshOrders_Click" />
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvOrders" runat="server" AutoGenerateColumns="False" OnRowCommand="gvOrders_RowCommand"
                                CssClass="table table-hover align-middle mb-0 mobile-card-table" GridLines="None" EmptyDataText="No orders found.">
                                <HeaderStyle CssClass="bg-light text-muted small text-uppercase fw-bold border-bottom" />
                                <Columns>
                                    <asp:BoundField DataField="OrderId" HeaderText="Order #" ReadOnly="true" />
                                    <asp:BoundField DataField="ProductName" HeaderText="Product" ReadOnly="true" />
                                    <asp:BoundField DataField="Quantity" HeaderText="Qty" ReadOnly="true" />
                                    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="${0:0.00}" ReadOnly="true" />
                                    <asp:BoundField DataField="TotalAmount" HeaderText="Total" DataFormatString="${0:0.00}" ReadOnly="true" />
                                    <asp:BoundField DataField="CustomerName" HeaderText="Customer" ReadOnly="true" />
                                    <asp:BoundField DataField="OrderDate" HeaderText="Date" DataFormatString="{0:MMM dd, yyyy}" ReadOnly="true" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='badge rounded-pill <%# GetOrderStatusBadge(Eval("OrderStatus").ToString()) %>'><%# Eval("OrderStatus") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                            <div class="p-3 border-top">
                                <uc:Pagination ID="ordersPagination" runat="server" OnPageChanged="ordersPagination_PageChanged" OnPageSizeChanged="ordersPagination_PageSizeChanged" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TAB 4: STATISTICS -->
                <div class="tab-pane fade" id="stats">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <div class="stat-card bg-gradient-primary">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblTotalProducts" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Total Products</div>
                                <i class="fas fa-box stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-card bg-gradient-success">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblApprovedProducts" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Approved</div>
                                <i class="fas fa-check-circle stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-card bg-gradient-warning">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblPendingProducts" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Pending</div>
                                <i class="fas fa-clock stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-card bg-gradient-danger">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblRejectedProducts" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Rejected</div>
                                <i class="fas fa-times-circle stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-card bg-gradient-info">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Total Orders</div>
                                <i class="fas fa-shopping-bag stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-card bg-gradient-dark">
                                <h3 class="fw-bold mb-1">$<asp:Label ID="lblTotalRevenue" runat="server" Text="0.00"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Revenue</div>
                                <i class="fas fa-wallet stat-icon-bg"></i>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-card bg-gradient-secondary">
                                <h3 class="fw-bold mb-1"><asp:Label ID="lblOutOfStock" runat="server" Text="0"></asp:Label></h3>
                                <div class="small opacity-75 text-uppercase fw-bold">Out of Stock</div>
                                <i class="fas fa-exclamation-triangle stat-icon-bg"></i>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Image Modal -->
    <div class="modal fade" id="imageModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center p-4">
                    <img id="modalImg" src="" class="img-fluid rounded shadow-sm" />
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function setActiveTab(tabName) {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf) hf.value = tabName;
        }

        document.addEventListener('DOMContentLoaded', function () {
            var activeTab = document.getElementById('<%= hfActiveTab.ClientID %>').value || 'add-product';

            // FIX 1: CLEAR ALL TAB CLASSES MANUALLY BEFORE ACTIVATING
            // This ensures "Add Product" doesn't stay visible when "My Products" is selected via PostBack
            var tabs = document.querySelectorAll('.nav-link');
            tabs.forEach(function (tab) { tab.classList.remove('active'); });
            var tabContents = document.querySelectorAll('.tab-pane');
            tabContents.forEach(function (content) { content.classList.remove('show', 'active'); });
            
            // Bootstrap 5 Tab API
            var triggerEl = document.querySelector('#' + activeTab + '-tab');
            if (triggerEl) {
                var tab = new bootstrap.Tab(triggerEl);
                tab.show();
            }

            // FIX 2: HIDE PRODUCT TABLE IF EDITING
            // If the Edit Panel (server control) is rendered, hide the main list
            var editPanel = document.getElementById('<%= pnlEditProduct.ClientID %>');
            var listContainer = document.getElementById('productListContainer');
            if (editPanel && listContainer) {
                listContainer.style.display = 'none';
            }
        });

        function showImageModal(url) {
            document.getElementById('modalImg').src = url;
            var myModal = new bootstrap.Modal(document.getElementById('imageModal'));
            myModal.show();
        }

        function filterProductTable() {
            var input = document.getElementById("txtSearchProduct");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("<%= gvProducts.ClientID %>");
            var tr = table.getElementsByTagName("tr");
            for (var i = 1; i < tr.length; i++) {
                var rowContent = tr[i].textContent || tr[i].innerText;
                if (rowContent) {
                    tr[i].style.display = rowContent.toUpperCase().indexOf(filter) > -1 ? "" : "none";
                }
            }
        }

        function filterOrderTable() {
            var input = document.getElementById("txtSearchOrder");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("<%= gvOrders.ClientID %>");
            var tr = table.getElementsByTagName("tr");
            for (var i = 1; i < tr.length; i++) {
                var rowContent = tr[i].textContent || tr[i].innerText;
                if (rowContent) {
                    tr[i].style.display = rowContent.toUpperCase().indexOf(filter) > -1 ? "" : "none";
                }
            }
        }
    </script>
</asp:Content>