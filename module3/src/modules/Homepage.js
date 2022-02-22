import Axios from 'axios';
import React, { useContext, useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { LoginContext } from '../contexts/LoginContext';
import { API_URL } from '../Constants';

function Homepage() {
    const [loggedInUser, setLoggedInUser] = useState({
        ccNumber: 0,
        ccName: "Dummy Card",
        userName: "Guest User",
        userId: "guest",
        availableRedeemPoints: 0,
        totalRewardsGained: 0
    })

    const userLogInContext = useContext(LoginContext);
    const isLoggedIn = userLogInContext.isLoggedIn

    // Make sure it only retrieve user data once
    useEffect(() => {
        if (isLoggedIn) {
            Axios.get(API_URL + '/ccuser/getuserbyuserid?userId=' + userLogInContext.loggedInUser.ccNumber).then(response => {

                // updating the login context
                setLoggedInUser(response.data.body)
            })
            console.log("here")
        }
      }, []);


    return (
        <div className="homepage container">
            <h2>Welcome to SmartBank credit card</h2>

            <div className="user-detail">

                {
                    isLoggedIn ?
                        (
                            <div>

                                <table className="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Credit Card Number</th>
                                            <th>Card Name</th>
                                            <th>User Name</th>
                                            <th>Available Points</th>
                                            <th>Total Rewards Gained (<i className="fas fa-rupee-sign"></i>)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>{loggedInUser.ccNumber}</td>
                                            <td>{loggedInUser.ccName}</td>
                                            <td>{loggedInUser.userName}</td>
                                            <td>{loggedInUser.availableRedeemPoints}</td>
                                            <td>{loggedInUser.totalRewardsGained}</td>
                                        </tr>
                                    </tbody>



                                </table>

                            </div>
                        ) :
                        (
                            <div className="mt-5">
                                Please Sign in to redeem your points. &nbsp; &nbsp;
                                <Link className="btn btn-primary" to="/login">
                                    <i className="fas fa-user" />&nbsp; Sign in

                                </Link>
                            </div>
                        )
                }


            </div>
        </div>
    );
}

export default Homepage;