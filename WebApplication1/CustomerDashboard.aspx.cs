using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.AspNet.Identity;
using WebApplication1.Helpers;
using WebApplication1.Controls;

namespace WebApplication1
{
    public partial class CustomerDashboard : Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        
        // Manual control declarations (normally auto-generated)
        protected Repeater rptOrdersMobile;
        protected Controls.PaginationControl ordersPagination;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user is authenticated and is a Customer
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            if (!User.IsInRole("Customer"))
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadOrdersWithPagination(1, 10); // Start with page 1, 10 records per page
            }
        }

        private void LoadOrdersWithPagination(int currentPage, int pageSize)
        {
            try
            {
                string customerId = User.Identity.GetUserId();

                // Validate pagination parameters
                PaginationHelper.ValidatePaginationParams(ref currentPage, ref pageSize);

                // Build queries
                string baseQuery = @"
                    SELECT OrderId, OrderDate, TotalAmount, Status, PaymentMethod
                    FROM Orders
                    WHERE CustomerId = @CustomerId";

                string countQuery = @"
                    SELECT COUNT(*)
                    FROM Orders
                    WHERE CustomerId = @CustomerId";

                string orderByClause = "ORDER BY OrderDate DESC";

                var parameters = new SqlParameter[]
                {
                    new SqlParameter("@CustomerId", customerId)
                };

                // Get paginated data
                var result = PaginationHelper.GetPaginatedData(
                    connStr, baseQuery, countQuery, orderByClause, 
                    parameters, currentPage, pageSize);

                if (result.TotalRecords > 0)
                {
                    // Bind data to both desktop and mobile views
                    gvOrders.DataSource = result.Data;
                    gvOrders.DataBind();
                    
                    rptOrdersMobile.DataSource = result.Data;
                    rptOrdersMobile.DataBind();

                    // Update pagination control
                    ordersPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
                    
                    pnlOrders.Visible = true;
                    lblMessage.Visible = false;
                }
                else
                {
                    // No orders found
                    gvOrders.DataSource = null;
                    gvOrders.DataBind();
                    
                    rptOrdersMobile.DataSource = null;
                    rptOrdersMobile.DataBind();

                    ordersPagination.Reset();
                    ShowMessage("You haven't placed any orders yet. Start shopping now!", "alert-info");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading orders: {ex}");
                ShowMessage("Error loading orders. Please try again later.", "alert-danger");
            }
        }

        protected void ordersPagination_PageChanged(object sender, PageChangedEventArgs e)
        {
            LoadOrdersWithPagination(e.CurrentPage, e.PageSize);
        }

        protected void ordersPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
        {
            LoadOrdersWithPagination(e.CurrentPage, e.PageSize);
        }

        private void LoadOrders()
        {
            // Keep the original method for backward compatibility
            // but redirect to the paginated version
            LoadOrdersWithPagination(1, 10);
        }

        protected void gvOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                LoadOrderDetails(orderId);
            }
        }

        protected void MobileViewDetails_Command(object sender, CommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                LoadOrderDetails(orderId);
            }
        }

        private void LoadOrderDetails(int orderId)
        {
            try
            {
                string customerId = User.Identity.GetUserId();

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // Get order details - verify it belongs to this customer
                    string orderQuery = @"
                        SELECT OrderId, CustomerName, Address, Phone, Email, PaymentMethod, TotalAmount, OrderDate, Status
                        FROM Orders
                        WHERE OrderId = @OrderId AND CustomerId = @CustomerId";

                    using (SqlCommand cmd = new SqlCommand(orderQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        cmd.Parameters.AddWithValue("@CustomerId", customerId);

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
                                
                                // Get status and handle null/empty values
                                string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString().Trim() : "Pending";
                                
                                // Debug: Add some logging to see what we're getting
                                System.Diagnostics.Trace.WriteLine($"Debug: Order {orderId} Status from DB: '{status}' (Length: {status.Length})");
                                
                                // Ensure we have a valid status
                                if (string.IsNullOrWhiteSpace(status))
                                {
                                    status = "Pending";
                                }
                                
                                lblStatus.Text = status;
                                lblPaymentMethod.Text = reader["PaymentMethod"].ToString();
                                lblTotalAmount.Text = Convert.ToDecimal(reader["TotalAmount"]).ToString("0.00");

                                // Set status badge color - ensure we always have the base badge class
                                string badgeClass = "badge ";
                                switch (status.ToLower())
                                {
                                    case "pending":
                                        badgeClass += "badge-warning";
                                        break;
                                    case "completed":
                                        badgeClass += "badge-success";
                                        break;
                                    case "cancelled":
                                        badgeClass += "badge-danger";
                                        break;
                                    case "shipped":
                                        badgeClass += "badge-primary";
                                        break;
                                    case "processing":
                                        badgeClass += "badge-secondary";
                                        break;
                                    default:
                                        badgeClass += "badge-info";
                                        break;
                                }
                                lblStatus.CssClass = badgeClass;
                                
                                // Debug: Log the final values
                                System.Diagnostics.Trace.WriteLine($"Debug: lblStatus.Text = '{lblStatus.Text}', lblStatus.CssClass = '{lblStatus.CssClass}'");
                            }
                            else
                            {
                                ShowMessage("Order not found or you don't have permission to view it.", "alert-danger");
                                return;
                            }
                        }
                    }

                    // Get order items
                    string itemsQuery = @"
                        SELECT ProductName, Quantity, Price
                        FROM OrderItems
                        WHERE OrderId = @OrderId";

                    using (SqlCommand cmd = new SqlCommand(itemsQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);

                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        rptOrderItems.DataSource = dt;
                        rptOrderItems.DataBind();
                    }

                    pnlOrderDetails.Visible = true;
                    pnlOrders.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading order details: {ex}");
                ShowMessage("Error loading order details. Please try again.", "alert-danger");
            }
        }

        protected void btnCloseDetails_Click(object sender, EventArgs e)
        {
            // Clear the form data to ensure fresh state
            ClearOrderDetails();
            pnlOrderDetails.Visible = false;
            pnlOrders.Visible = true;
        }

        private void ClearOrderDetails()
        {
            lblOrderId.Text = "";
            lblCustomerName.Text = "";
            lblPhone.Text = "";
            lblEmail.Text = "";
            lblAddress.Text = "";
            lblOrderDate.Text = "";
            lblStatus.Text = "";
            lblStatus.CssClass = "badge badge-info"; // Reset to default
            lblPaymentMethod.Text = "";
            lblTotalAmount.Text = "";
            rptOrderItems.DataSource = null;
            rptOrderItems.DataBind();
        }

        protected void btnContinueShopping_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert {cssClass}";
            lblMessage.Visible = true;
        }

        protected string GetStatusBadgeClass(string status)
        {
            if (string.IsNullOrEmpty(status))
                return "badge-secondary";

            switch (status.ToLower())
            {
                case "pending":
                    return "badge-warning";
                case "completed":
                    return "badge-success";
                case "cancelled":
                    return "badge-danger";
                case "shipped":
                    return "badge-primary";
                case "processing":
                    return "badge-info";
                default:
                    return "badge-secondary";
            }
        }
    }
}
