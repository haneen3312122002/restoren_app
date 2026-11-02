namespace restoren_app.Data.Models
{
    // Order steps in order. An order moves one step forward until it is Delivered.
    public enum OrderStatus
    {
        Pending,
        Preparing,
        Ready,
        Delivered
    }

    // Eat in the restaurant or take away
    public enum OrderType
    {
        DineIn,
        Takeaway
    }
}
