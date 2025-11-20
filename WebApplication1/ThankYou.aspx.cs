using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace WebApplication1
{
    public partial class ThankYou : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOrderDetails();
            }
        }

        private void LoadOrderDetails()
        {
            try
            {
                // Get order ID from session
                if (Session["LastOrderId"] == null)
                {
                    ShowError("No order information found.");
                    return;
                }

                int orderId = Convert.ToInt32(Session["LastOrderId"]);
                
                // Load order from database
                LoadOrderFromDatabase(orderId);

                // Clear the session variable
                Session.Remove("LastOrderId");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in LoadOrderDetails: {ex}");
                ShowError("Unable to load order details.");
            }
        }

        private void LoadOrderFromDatabase(int orderId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get order details
                string orderQuery = @"
                    SELECT OrderId, CustomerName, Address, Phone, Email, PaymentMethod, TotalAmount, OrderDate, Status
                    FROM Orders
                    WHERE OrderId = @OrderId";

                using (SqlCommand cmd = new SqlCommand(orderQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblOrderId.Text = reader["OrderId"].ToString();
                            lblOrderDate.Text = Convert.ToDateTime(reader["OrderDate"]).ToString("MMMM dd, yyyy hh:mm tt");
                            lblCustomerName.Text = reader["CustomerName"].ToString();
                            lblPhone.Text = reader["Phone"].ToString();
                            lblAddress.Text = reader["Address"].ToString();
                            lblTotalAmount.Text = Convert.ToDecimal(reader["TotalAmount"]).ToString("0.00");
                        }
                        else
                        {
                            ShowError("Order not found.");
                            return;
                        }
                    }
                }

                // Get order items
                string itemsQuery = @"
                    SELECT ProductName, Quantity, Price
                    FROM OrderItems
                    WHERE OrderId = @OrderId";

                using (SqlCommand cmd = new SqlCommand(itemsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);

                    rptOrderItems.DataSource = dt;
                    rptOrderItems.DataBind();
                }

                pnlOrderDetails.Visible = true;
                pnlError.Visible = false;
            }
        }

        protected void btnContinueShopping_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = true;
            pnlOrderDetails.Visible = false;
        }
    }
}
