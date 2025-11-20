using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication1.Helpers;

namespace WebApplication1
{
    public partial class Cart : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is authenticated
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=~/Cart.aspx");
                return;
            }

            // Check if user is a Customer
            if (!User.IsInRole("Customer"))
            {
                ShowMessage("Only customers can access the shopping cart.", "alert-warning");
                btnCheckout.Enabled = false;
                return;
            }

            if (!IsPostBack)
            {
                BindCart();
            }
        }

        private void BindCart()
        {
            var cart = CartHelper.GetCart(Session);

            if (cart == null || cart.Count == 0)
            {
                pnlCart.Visible = false;
                pnlEmptyCart.Visible = true;
                return;
            }

            pnlCart.Visible = true;
            pnlEmptyCart.Visible = false;

            rptCartItems.DataSource = cart;
            rptCartItems.DataBind();

            decimal total = CartHelper.GetCartTotal(Session);
            lblTotal.Text = total.ToString("0.00");
        }

        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                int productId = Convert.ToInt32(e.CommandArgument);

                if (e.CommandName == "Remove")
                {
                    CartHelper.RemoveFromCart(Session, productId);
                    ShowMessage("Item removed from cart.", "alert-success");
                }
                else if (e.CommandName == "Update")
                {
                    var txtQuantity = e.Item.FindControl("txtQuantity") as TextBox;
                    if (txtQuantity != null && int.TryParse(txtQuantity.Text, out int quantity))
                    {
                        if (quantity > 0)
                        {
                            CartHelper.UpdateQuantity(Session, productId, quantity);
                            ShowMessage("Quantity updated.", "alert-success");
                        }
                        else
                        {
                            ShowMessage("Quantity must be at least 1.", "alert-warning");
                        }
                    }
                }

                BindCart();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error in rptCartItems_ItemCommand: {ex}");
                ShowMessage("An error occurred. Please try again.", "alert-danger");
            }
        }

        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            var cart = CartHelper.GetCart(Session);
            if (cart == null || cart.Count == 0)
            {
                ShowMessage("Your cart is empty.", "alert-warning");
                return;
            }

            Response.Redirect("~/Checkout.aspx");
        }

        protected void btnContinueShopping_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }

        protected void btnShopNow_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }

        private void ShowMessage(string message, string cssClass)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = $"alert {cssClass}";
            lblMessage.Visible = true;
        }
    }
}
