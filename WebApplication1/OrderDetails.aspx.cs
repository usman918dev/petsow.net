using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using Microsoft.AspNet.Identity;

namespace WebApplication1
{
    public partial class OrderDetails : Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!User.IsInRole("Admin") && !User.IsInRole("Seller"))
            {
                ShowError("Access denied. Only administrators and sellers can view order details.");
                return;
            }

            if (!IsPostBack)
            {
                LoadOrderDetails();
            }
        }

        private void LoadOrderDetails()
        {
            try
            {
                string orderIdStr = Request.QueryString["orderId"];
                
                if (string.IsNullOrEmpty(orderIdStr) || !int.TryParse(orderIdStr, out int orderId))
                {
                    ShowError("Invalid order ID.");
                    return;
                }

                string userId = User.Identity.GetUserId();
                bool isAdmin = User.IsInRole("Admin");
                bool isSeller = User.IsInRole("Seller");

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    string orderQuery = @"
                        SELECT o.OrderId, o.CustomerName, o.Address, o.Phone, o.Email, 
                               o.PaymentMethod, o.TotalAmount, o.OrderDate, o.Status, o.CustomerId
                        FROM Orders o";

                    if (isSeller && !isAdmin)
                    {
                        orderQuery += @"
                            INNER JOIN OrderItems oi ON o.OrderId = oi.OrderId
                            INNER JOIN PetSupplies ps ON oi.ProductId = ps.Id
                            WHERE o.OrderId = @OrderId AND ps.SellerId = @UserId";
                    }
                    else
                    {
                        orderQuery += " WHERE o.OrderId = @OrderId";
                    }

                    using (SqlCommand cmd = new SqlCommand(orderQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        if (isSeller && !isAdmin)
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                        }

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblOrderId.Text = reader["OrderId"].ToString();
                                lblCustomerName.Text = reader["CustomerName"].ToString();
                                lblPhone.Text = reader["Phone"].ToString();
                                lblEmail.Text = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "N/A";
                                lblAddress.Text = reader["Address"].ToString();
                                lblOrderDate.Text = Convert.ToDateTime(reader["OrderDate"]).ToString("MMMM dd, yyyy hh:mm tt");
                                lblPaymentMethod.Text = reader["PaymentMethod"].ToString();
                                lblTotalAmount.Text = Convert.ToDecimal(reader["TotalAmount"]).ToString("0.00");
                                
                                string status = reader["Status"].ToString();
                                lblStatus.Text = status;
                                SetStatusBadge(status);

                                if (isAdmin)
                                {
                                    pnlAdminControls.Visible = true;
                                    ddlUpdateStatus.SelectedValue = status;
                                }

                                pnlOrderDetails.Visible = true;
                            }
                            else
                            {
                                ShowError("Order not found or you don't have permission to view it.");
                                return;
                            }
                        }
                    }

                    LoadOrderItems(orderId, userId, isAdmin, isSeller);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading order details: {ex}");
                ShowError("An error occurred while loading order details.");
            }
        }

        private void LoadOrderItems(int orderId, string userId, bool isAdmin, bool isSeller)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string itemsQuery = @"
                        SELECT oi.ProductId, oi.ProductName, oi.Quantity, oi.Price,
                               ISNULL(ps.SellerName, 'Unknown') as SellerName,
                               ISNULL(u.Email, 'No email provided') as SellerEmail
                        FROM OrderItems oi
                        LEFT JOIN PetSupplies ps ON oi.ProductId = ps.Id
                        LEFT JOIN AspNetUsers u ON ps.SellerId = u.Id
                        WHERE oi.OrderId = @OrderId";

                    if (isSeller && !isAdmin)
                    {
                        itemsQuery += " AND ps.SellerId = @UserId";
                    }

                    itemsQuery += " ORDER BY oi.ProductName";

                    using (SqlCommand cmd = new SqlCommand(itemsQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        if (isSeller && !isAdmin)
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                        }

                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        gvOrderItems.DataSource = dt;
                        gvOrderItems.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading order items: {ex}");
                ShowError("Error loading order items.");
            }
        }

        private void SetStatusBadge(string status)
        {
            switch (status?.ToLower())
            {
                case "pending":
                    lblStatus.CssClass = "badge bg-warning fs-6 px-3 py-2";
                    break;
                case "processing":
                    lblStatus.CssClass = "badge bg-info fs-6 px-3 py-2";
                    break;
                case "shipped":
                    lblStatus.CssClass = "badge bg-primary fs-6 px-3 py-2";
                    break;
                case "delivered":
                    lblStatus.CssClass = "badge bg-success fs-6 px-3 py-2";
                    break;
                case "completed":
                    lblStatus.CssClass = "badge bg-success fs-6 px-3 py-2";
                    break;
                case "cancelled":
                    lblStatus.CssClass = "badge bg-danger fs-6 px-3 py-2";
                    break;
                default:
                    lblStatus.CssClass = "badge bg-secondary fs-6 px-3 py-2";
                    break;
            }
        }

        protected void btnUpdateStatus_Click(object sender, EventArgs e)
        {
            if (!User.IsInRole("Admin"))
            {
                ShowError("Only administrators can update order status.");
                return;
            }

            try
            {
                string orderIdStr = Request.QueryString["orderId"];
                if (string.IsNullOrEmpty(orderIdStr) || !int.TryParse(orderIdStr, out int orderId))
                {
                    ShowError("Invalid order ID.");
                    return;
                }

                string newStatus = ddlUpdateStatus.SelectedValue;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string updateQuery = "UPDATE Orders SET Status = @Status WHERE OrderId = @OrderId";
                    
                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@OrderId", orderId);

                        con.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            LoadOrderDetails();
                            ShowSuccess($"Order status updated to '{newStatus}' successfully.");
                        }
                        else
                        {
                            ShowError("Failed to update order status.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error updating order status: {ex}");
                ShowError("An error occurred while updating order status.");
            }
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            if (User.IsInRole("Admin"))
            {
                Response.Redirect("~/AdminDashboard.aspx");
            }
            else if (User.IsInRole("Seller"))
            {
                Response.Redirect("~/SellerDashboard.aspx");
            }
            else
            {
                Response.Redirect("~/Default.aspx");
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.CssClass = "alert alert-danger border-0 shadow-sm";
            lblError.Visible = true;
            pnlOrderDetails.Visible = false;
        }

        private void ShowSuccess(string message)
        {
            lblError.Text = message;
            lblError.CssClass = "alert alert-success border-0 shadow-sm";
            lblError.Visible = true;
        }
    }
}