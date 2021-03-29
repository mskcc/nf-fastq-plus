import React from 'react';

import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';

import TrackerView from './components/tracker-view';
import Header from './components/header';

import './App.css';

const theme = createMuiTheme({
  typography: {
    useNextVariants: true,
  },
  palette: {
    primary: {
      logo: '#319ae8',
      light: '#8FC7E8',
      main: '#007CBA',
      dark: '#006098',
    },
    secondary: {
      light: '#F6C65B',
      main: '#DF4602',
      dark: '#C24D00',
    },

    textSecondary: '#e0e0e0',
  },
});

function App() {
  return (
    <MuiThemeProvider theme={theme}>
      <Router>
        <Header />
        <Switch>
          <Route path='/' component={TrackerView} />
        </Switch>
      </Router>
    </MuiThemeProvider>
  );
}

export default App;
