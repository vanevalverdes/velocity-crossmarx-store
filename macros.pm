## This file is generated. Do not edit!
## This file contains 3 macros.

#macro(checkloginstate)
	#if($session.getVariable('uid'))
		#set($user = $session.getRecord('Customer', "$session.getVariable('uid')"))
		#set($tokentocheck =  $engine.getMD5encodedString("$user.get('Token')|$user.get('Email').substring(0, 4)|1"))
		#if($tokentocheck != $session.getVariable('sid')) 
			$session.getReplaceScript("/crear-cuenta?origin=$request")
		#else
			#set($loggedin = true)
		#end
	#else
		$session.getReplaceScript("/crear-cuenta?origin=$request")
	#end
#end



#macro(getCart)
	#set($cart = $session.getVariable('cart'))
	#set($orderlines = $session.getVariable('orderlines'))
	#if(!$cart)  
		#set($cart = $session.newRecord('Order'))
		$session.putVariable('cart', $cart)
		#set($orderlines = $cart.getRelevantConnectedTable('Orderline'))
		$session.putVariable('orderlines', $orderlines)
	#end

	#if($cart && $session.getVariable("discount"))
		$cart.putVoid("Discount Code", "2020")
	#end
## Add To Cartl

	#set($product = $request.getInteger('product'))
	#set($amount = $request.getInteger('amount'))

	#if($product && $amount)
			#set($newLine = $orderlines.addRecord())
			$newLine.putVoid('product', $product)
			$newLine.putVoid('Quantity', $amount)
		$cart.forceCalculateAllFields()
		#if($request.get("payment"))
			$session.getReplaceScript("/direccion-envio")
		#else
			$session.getReplaceScript("/carrito")
		#end
	#end

## Save	

	#if($save && $orderlines.size() > 0)
		#set($void = $cart.store('User', $session.getVariable('uid')))
		#set($savedCart = $cart.saveWithConnectedTables(true))
		
		#foreach($orderline in $orderlines)
			$orderline.forceCalculateAllFields()
			#set($savedOrderline = $orderline.saveWithConnectedTables(true))
		#end
		#if(!$record.get('Status'))
			#set($newstatus = $session.newRecord("Status Update"))
			$newstatus.putVoid("Order", $cart.getSingleKeyValue())
			$newstatus.putVoid("Status", 1)
			#set($void = $newstatus.save())
		#end
	#end

## Delete an orderline
	#set($delete = $request.getInteger('delete'))
	#if($delete)
		#if($orderlines.get($delete))
			#set($orderlineToDelete = $orderlines.get($delete))
			$orderlines.remove($orderlineToDelete)
			$cart.forceCalculateAllFields()
		#end
	#end

## Clear order and cart

	#if($request.get('neworder') == true)
		$session.removeVariable('cart')
		$session.removeVariable('orderlines')	
	#end




#end



#macro(logCart)
#if($session.getVariable("uid"))
	#set($cartlog = $session.newRecord('Cart Log'))
	$cartlog.putVoid('User', $session.getVariable("uid"))
	$cartlog.putVoid('Log', "#foreach($orderline in $orderlines)$orderline.toJSON()#end")
	$cartlog.putVoid("Total", $orderlines.getSum("Total"))
	#set($void = $cartlog.save())
#end
#end



