import React from 'react';
import { BrowserRouter } from 'react-router-dom'
import './App.css';
import AppHeader from './components/AppHeader';
import LoginContextProvider from './contexts/LoginContext';
import CartContextProvider from './contexts/CartContext';
// test
// test2
function App() {

  return (

    <BrowserRouter>

      <div className="App">

        <LoginContextProvider>
          <CartContextProvider>
            <AppHeader />
          </CartContextProvider>
        </LoginContextProvider>


      </div>

    </BrowserRouter>
  );
}


export default App;
