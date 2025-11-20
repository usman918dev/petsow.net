using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using WebApplication1.Helpers;
using Microsoft.AspNet.Identity;

namespace WebApplication1
{
    public partial class Checkout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user is authenticated and is a Customer
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=~/Cart.aspx");
                return;
            }

            if (!User.IsInRole("Customer"))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                var cart = CartHelper.GetCart(Session);
                
                // Redirect if cart is empty
                if (cart == null || cart.Count == 0)
                {
                    Response.Redirect("~/Cart.aspx");
                    return;
                }

                BindOrderSummary();
            }
        }

        private void BindOrderSummary()
        {
            var cart = CartHelper.GetCart(Session);
            rptOrderSummary.DataSource = cart;
            rptOrderSummary.DataBind();

            decimal total = CartHelper.GetCartTotal(Session);
            lblTotal.Text = total.ToString("0.00");
        }

        protected void btnConfirmOrder_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            // Double-check user is authenticated and is a Customer
            if (!User.Identity.IsAuthenticated || !User.IsInRole("Customer"))
            {
                ShowError("Only customers can place orders.");
                return;
            }

            try
            {
                var cart = CartHelper.GetCart(Session);
                
                if (cart == null || cart.Count == 0)
                {
                    ShowError("Your cart is empty.");
                    return;
                }

                decimal totalAmount = CartHelper.GetCartTotal(Session);
                string customerId = User.Identity.GetUserId();

                // Save order to database
                int orderId = SaveOrderToDatabase(
                    customerId,
                    txtName.Text.Trim(), 
                    txtAddress.Text.Trim(), 
                    txtPhone.Text.Trim(), 
                    txtEmail.Text.Trim(), 
                    totalAmount, 
                    cart);

                if (orderId > 0)
                {
                    // Clear cart
                    CartHelper.ClearCart(Session);

                    // Store order ID in session for thank you page
                    Session["LastOrderId"] = orderId;

                    // Redirect to thank you page
                    Response.Redirect("~/ThankYou.aspx");
                }
                else
                {
                    ShowError("Failed to place order. Please try again.");
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error details: " + ex.Message;
                lblError.Visible = true;
                System.Diagnostics.Trace.TraceError($"Error in btnConfirmOrder_Click: {ex}");
            }
        }

        private int SaveOrderToDatabase(string customerId, string customerName, string address, string phone, string email, decimal totalAmount, System.Collections.Generic.List<Models.CartItem> cart)
        {
            int orderId = 0;
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    // Insert into Orders table
                    string orderQuery = @"
                        INSERT INTO Orders (CustomerId, CustomerName, Address, Phone, Email, PaymentMethod, TotalAmount, OrderDate, Status)
                        VALUES (@CustomerId, @CustomerName, @Address, @Phone, @Email, @PaymentMethod, @TotalAmount, @OrderDate, @Status);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    using (SqlCommand cmd = new SqlCommand(orderQuery, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@CustomerId", customerId);
                        cmd.Parameters.AddWithValue("@CustomerName", customerName);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                        cmd.Parameters.AddWithValue("@PaymentMethod", "Cash on Delivery");
                        cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                        cmd.Parameters.AddWithValue("@OrderDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@Status", "Pending");

                        orderId = (int)cmd.ExecuteScalar();
                    }

                    // Insert order items
                    string orderItemQuery = @"
                        INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, Price)
                        VALUES (@OrderId, @ProductId, @ProductName, @Quantity, @Price);";

                    foreach (var item in cart)
                    {
                        using (SqlCommand cmd = new SqlCommand(orderItemQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@OrderId", orderId);
                            cmd.Parameters.AddWithValue("@ProductId", item.ProductId);
                            cmd.Parameters.AddWithValue("@ProductName", item.ProductName);
                            cmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                            cmd.Parameters.AddWithValue("@Price", item.Price);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();
                }
                catch (Exception)
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return orderId;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Cart.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }
}
