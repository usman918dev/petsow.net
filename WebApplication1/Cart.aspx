<%@ Page Title="Shopping Cart" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="WebApplication1.Cart" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<style>

    .cart-table-container {
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e5e7eb;
        margin-bottom: 30px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    /* ---- Header (Desktop) ---- */
    .cart-table th {
        background: #2c2c2c;
        color: white;
        padding: 16px;
        font-size: 0.85rem;
        text-transform: uppercase;
        font-weight: 600;
        border: none;
    }

    /* ---- Table Rows ---- */
    .cart-table td {
        padding: 18px 16px;
        border-bottom: 1px solid #efefef;
        vertical-align: middle;
        font-size: 0.95rem;
        color: #333;
    }

    .cart-table tr:last-child td {
        border-bottom: none;
    }

    /* ---- Product image ---- */
    .cart-item-image {
        width: 70px;
        height: 70px;
        border-radius: 8px;
        object-fit: cover;
        margin-right: 14px;
        border: 1px solid #eee;
    }

    /* ---- Product details ---- */
    .product-info {
        display: flex;
        align-items: center;
    }

    .product-name {
        font-weight: 600;
        color: #222;
        margin-bottom: 4px;
    }

    .product-sku {
        font-size: 0.78rem;
        color: #777;
    }

    /* ---- Price & Subtotal ---- */
    .price-display,
    .subtotal-display {
        font-weight: 700;
        font-size: 1.05rem;
        color: #2c2c2c;
    }

    /* ---- Quantity ---- */
    .quantity-container {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .quantity-input {
        width: 60px;
        text-align: center;
        border: 1px solid #dcdcdc;
        padding: 6px;
        border-radius: 6px;
        font-weight: 600;
    }

    /* ---- Buttons ---- */
    .btn-update-cart,
    .btn-remove-cart {
        border: none;
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        color: white;
        transition: opacity 0.2s;
    }

    .btn-update-cart { background: #17a2b8; }
    .btn-remove-cart { background: #dc3545; }

    .btn-update-cart:hover,
    .btn-remove-cart:hover { opacity: 0.85; }

    /* ======================================================
       MOBILE VIEW – Modern Card Layout with Labels
       ====================================================== */
    @media (max-width: 768px) {

        .cart-table thead {
            display: none;
        }

        .cart-table tbody tr {
            display: block;
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            margin-bottom: 15px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            position: relative; /* Anchor for absolute positioning */
        }

        .cart-table td {
            display: flex;
            justify-content: space-between; /* Pushes Label to left, Value to right */
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px dashed #eee;
            text-align: right;
        }

        .cart-table td:last-child {
            border-bottom: none;
        }

        /* 1. Enable Labels using ::before */
        .cart-table td::before {
            content: attr(data-label);
            font-weight: 700;
            color: #6c757d;
            font-size: 0.85rem;
            text-transform: uppercase;
            margin-right: auto; /* Ensures flex spacing works nicely */
        }

        /* 2. Special Styling for Product Row (First Row) */
        td[data-label="Product"] {
            flex-direction: row;
            justify-content: flex-start;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
            margin-bottom: 8px;
            padding-right: 40px; /* Space for delete button */
        }

        /* Hide the text label "Product" because the image is obvious */
        td[data-label="Product"]::before {
            display: none;
        }

        .cart-item-image {
            width: 60px;
            height: 60px;
        }

        /* 3. Special Styling for Delete Button (Action Row) */
        td[data-label="Action"] {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 0;
            border: none;
            width: auto;
            height: auto;
        }
        
        /* Hide the text label "Action" */
        td[data-label="Action"]::before {
            display: none;
        }

        .btn-remove-cart {
            background: transparent;
            color: #dc3545;
            font-size: 1.2rem;
        }
    }

</style>


<main class="container my-5">

  <h1 class="mb-4 fw-bold text-dark">
    <i class="fas fa-shopping-cart me-2 text-primary"></i> Shopping Cart
  </h1>

  <asp:Label ID="lblMessage" runat="server" CssClass="alert alert-info d-block mb-3" Visible="false"></asp:Label>

  <!-- ====================== CART PANEL ======================= -->
  <asp:Panel ID="pnlCart" runat="server" Visible="true">

    <div class="cart-table-container">
      <div class="table-responsive">

        <table class="table cart-table mb-0">
          <thead>
            <tr>
              <th style="width:45%">Product</th>
              <th style="width:15%">Price</th>
              <th style="width:20%">Qty</th>
              <th style="width:15%">Subtotal</th>
              <th style="width:5%"></th>
            </tr>
          </thead>

          <tbody>
            <asp:Repeater ID="rptCartItems" runat="server" OnItemCommand="rptCartItems_ItemCommand">
              <ItemTemplate>
                <tr>

                  <!-- PRODUCT -->
                  <td data-label="Product">
                    <div class="product-info">
                      <!-- CHANGED: Uses ResolveUrl -->
                      <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>' class="cart-item-image" alt="Product Image" />
                      <div>
                        <div class="product-name"><%# Eval("ProductName") %></div>
                        <div class="product-sku">ID: <%# Eval("ProductId") %></div>
                      </div>
                    </div>
                  </td>

                  <!-- PRICE -->
                  <td data-label="Price">
                    <div class="price-display">$<%# Eval("Price", "{0:0.00}") %></div>
                  </td>

                  <!-- QTY -->
                  <td data-label="Quantity">
                    <div class="quantity-container justify-content-end">
                      <asp:TextBox ID="txtQuantity" runat="server"
                        CssClass="quantity-input"
                        Text='<%# Eval("Quantity") %>' TextMode="Number" min="1" />
                      <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn-update-cart"
                        CommandName="Update" CommandArgument='<%# Eval("ProductId") %>' ToolTip="Update Quantity">
                        <i class="fas fa-sync-alt"></i>
                      </asp:LinkButton>
                    </div>
                  </td>

                  <!-- SUBTOTAL -->
                  <td data-label="Subtotal">
                    <div class="subtotal-display text-primary">$<%# Eval("Subtotal", "{0:0.00}") %></div>
                  </td>

                  <!-- DELETE -->
                  <td data-label="Action">
                    <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn-remove-cart"
                      CommandName="Remove" CommandArgument='<%# Eval("ProductId") %>'
                      OnClientClick="return confirm('Remove this item?');" ToolTip="Remove Item">
                      <i class="fas fa-trash-alt"></i>
                    </asp:LinkButton>
                  </td>

                </tr>
              </ItemTemplate>
            </asp:Repeater>
          </tbody>

        </table>

      </div>
    </div>

    <!-- ====================== BOTTOM TOTAL + BUTTONS ======================= -->
    <div class="card border-0 shadow-sm p-4 bg-light">
        <div class="row align-items-center">
          <div class="col-md-6 mb-3 mb-md-0">
            <asp:Button ID="btnContinueShopping" runat="server"
              Text="Continue Shopping"
              CssClass="btn btn-outline-secondary rounded-pill px-4"
              OnClick="btnContinueShopping_Click" />
          </div>

          <div class="col-md-6">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-end gap-3">
              <div class="text-end">
                <div class="text-muted small text-uppercase fw-bold">Total Amount</div>
                <div class="h3 mb-0 fw-bold text-dark">
                  $<asp:Label ID="lblTotal" runat="server"></asp:Label>
                </div>
              </div>

              <asp:Button ID="btnCheckout" runat="server" Text="Proceed to Checkout"
                CssClass="btn btn-dark btn-lg rounded-pill px-5 shadow-sm"
                OnClick="btnCheckout_Click" />
            </div>
          </div>
        </div>
    </div>

  </asp:Panel>

  <!-- ====================== EMPTY CART PANEL ======================= -->
  <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false">
    <div class="text-center py-5">
      <div class="mb-4">
          <i class="fas fa-shopping-basket fa-4x text-muted opacity-25"></i>
      </div>
      <h3 class="fw-bold text-secondary">Your cart is currently empty</h3>
      <p class="text-muted mb-4">Looks like you haven't added anything to your cart yet.</p>
      <asp:Button ID="btnShopNow" runat="server" Text="Start Shopping"
        CssClass="btn btn-primary btn-lg px-5 rounded-pill" OnClick="btnShopNow_Click" />
    </div>
  </asp:Panel>

</main>

</asp:Content>