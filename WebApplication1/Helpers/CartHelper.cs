using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApplication1.Models;

namespace WebApplication1.Helpers
{
    public static class CartHelper
    {
        private const string CartSessionKey = "Cart";

        public static List<CartItem> GetCart(System.Web.SessionState.HttpSessionState session)
        {
            var cart = session[CartSessionKey] as List<CartItem>;
            if (cart == null)
            {
                cart = new List<CartItem>();
                session[CartSessionKey] = cart;
            }
            return cart;
        }

        public static void AddToCart(System.Web.SessionState.HttpSessionState session, int productId, string productName, decimal price, string imageUrl, int quantity = 1)
        {
            var cart = GetCart(session);
            var existingItem = cart.FirstOrDefault(x => x.ProductId == productId);

            if (existingItem != null)
            {
                existingItem.Quantity += quantity;
            }
            else
            {
                cart.Add(new CartItem
                {
                    ProductId = productId,
                    ProductName = productName,
                    Price = price,
                    ImageUrl = imageUrl,
                    Quantity = quantity
                });
            }
        }

        public static void UpdateQuantity(System.Web.SessionState.HttpSessionState session, int productId, int quantity)
        {
            var cart = GetCart(session);
            var item = cart.FirstOrDefault(x => x.ProductId == productId);
            if (item != null)
            {
                if (quantity > 0)
                {
                    item.Quantity = quantity;
                }
                else
                {
                    cart.Remove(item);
                }
            }
        }

        public static void RemoveFromCart(System.Web.SessionState.HttpSessionState session, int productId)
        {
            var cart = GetCart(session);
            var item = cart.FirstOrDefault(x => x.ProductId == productId);
            if (item != null)
            {
                cart.Remove(item);
            }
        }

        public static decimal GetCartTotal(System.Web.SessionState.HttpSessionState session)
        {
            var cart = GetCart(session);
            return cart.Sum(x => x.Subtotal);
        }

        public static int GetCartItemCount(System.Web.SessionState.HttpSessionState session)
        {
            var cart = GetCart(session);
            return cart.Sum(x => x.Quantity);
        }

        public static void ClearCart(System.Web.SessionState.HttpSessionState session)
        {
            session[CartSessionKey] = new List<CartItem>();
        }
    }
}
