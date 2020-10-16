defmodule Exib.Order do

  def market_order(conid, side, quantity, cOID \\ "") do
    %{"cOID" => cOID, "conid" => conid, "orderType" => "MKT", "side" => side, "tif" => "GTC", "quantity" => quantity, "useAdaptive" => true}
  end

  def limit_order(conid, side, quantity, price, cOID \\ "") do
    %{"cOID" => cOID, "conid" => conid, "price" => price, "orderType" => "LMT", "side" => side, "tif" => "GTC", "quantity" => quantity, "useAdaptive" => true}
  end

  def set_parent(order, parentId) do
    Map.put(order, "parentId", parentId)
  end

end
