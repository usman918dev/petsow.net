using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin.Security;

namespace WebApplication1
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Show dashboard link based on user role
            if (Page.User.Identity.IsAuthenticated)
            {
                SetDashboardLink();
            }
            else
            {
                liDashboard.Visible = false;
            }
        }

        private void SetDashboardLink()
        {
            if (Page.User.IsInRole("Admin"))
            {
                liDashboard.Visible = true;
                aDashboard.InnerText = "Dashboard";
                aDashboard.HRef = "~/AdminDashboard.aspx";
            }
            else if (Page.User.IsInRole("Seller"))
            {
                liDashboard.Visible = true;
                aDashboard.InnerText = "Dashboard";
                aDashboard.HRef = "~/SellerDashboard.aspx";
            }
            else if (Page.User.IsInRole("Customer"))
            {
                liDashboard.Visible = true;
                aDashboard.InnerText = "Dashboard";
                aDashboard.HRef = "~/CustomerDashboard.aspx";
            }
            else
            {
                liDashboard.Visible = false;
            }
        }

        protected void Unnamed_LoggingOut(object sender, LoginCancelEventArgs e)
        {
            HttpContext.Current.GetOwinContext().Authentication.SignOut(DefaultAuthenticationTypes.ApplicationCookie);
        }
    }
}