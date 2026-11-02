namespace restoren_app.Data
{
    //  error messages 
    public static class ErrorMessages
    {
        public const string InvalidCredentials = "Invalid username or password.";
        public const string AccountLocked = "Account is locked. Try again in a few minutes.";
        public const string ProductNotFound = "Product does not exist.";
        public const string ProductUnavailable = "Product is currently unavailable.";
        public const string CategoryNotFound = "Category does not exist.";
        public const string OrderNotFound = "Order not found.";
        public const string QuantityOutOfRange = "Quantity must be between 1 and 50.";
        public const string EmptyOrder = "The order must contain at least one item.";
        public const string OrderAlreadyDelivered = "This order is already Delivered and its status cannot be changed.";
        public const string TooManyRequests = "Too many login attempts. Please try again later.";
    }
}
